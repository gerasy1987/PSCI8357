################################################################################
################# This R Script Does the Following: ############################
### Provides students in the recitation period with a chance to practice
### coding in R with a matching design. All coding uses the same motivating
### question, how does being asked to give a government employee a bribe
### recently (up to a year ago) affect your overall trust in the state?
################################################################################
### Load packages, data, set working directory, and prep parallel code
# Setting the working directory
# If you do not know the directory you are working out of, use getwd() first
setwd("/Users/alexdean/Documents/Vanderbilt/Service/Spring 2026/addl_material/")

# Packages
if (!require(tidyverse)) install.packages("tidyverse")
if (!require(MatchIt)) install.packages("MatchIt")
if (!require(cobalt)) install.packages("cobalt")
if (!require(rbounds)) install.packages("rbounds")
if (!require(modelsummary)) install.packages("modelsummary")
if (!require(kableExtra)) install.packages("kableExtra")
if (!require(parallel)) install.packages("parallel")

options(scipen = 999)

# Load data and name the loaded object `data` (hint, type ? haven if you're 
# having difficulty loading the data)
data <- haven::read_dta("matching/lapop_2023.dta")

### Parallelization
# Some of the code will take too long without running it in parallel, so let's 
# set up parallelization prep here

# Making results reproducible
RNGkind("L'Ecuyer-CMRG")
set.seed(032026)

# Setting no. cores and how parallelization will occur (with socket)
n_cores <- max(1, parallel::detectCores() - 1)
cl <- parallel::makeCluster(n_cores, type = "PSOCK")

##### Examining the data #######################################################
### Subsetting
# This code below will subset the code to only the relevant variables for our 
# analyses today, run it and ask if there are parts of the code that you don't
# understand why or how I wrote the specific code chunk
data <- data |> 
  select(
    pais, # country where respondent was surveyed
    estratopri, # subnational unit where respondent was surveyed (province, state, etc.)
    q2, # respondent's self-reported age
    q1tc_r, # respondent's self-reported gender
    edre, # Highest level of education
    q5b, # How important is religion in your daily life
    q10inc, # What is your income
    gi0n, # How often do you follow the news?
    smedia3n, # How often do you see political information on social media,
    exc6, # Were you asked for a bribe from govt. employee
    b13, # How much do you trust the congress
    b18, # How much do you trust the national police
    b21a, # How much do you trust the executive (president or PM)
    b21, # How much do you trust political parties
    b31, # How much do you trust the surpreme court
    b32, # How much do you trust your local government
    b37, # How much do you trust the mass media
    b47a, # How much do you trust elections in the country
  ) |> 
  rename(
    country = pais,
    province = estratopri,
    age = q2,
    gender = q1tc_r,
    educ = edre,
    religion_important = q5b,
    income = q10inc,
    follow_news = gi0n,
    soc_media_politics = smedia3n,
    asked_bribe = exc6,
    trust_cong = b13,
    trust_police = b18,
    trust_prez = b21a,
    trust_pol_party = b21,
    trust_court = b31,
    trust_local = b32,
    trust_media = b37,
    trust_election = b47a
  ) |> 
  arrange(country, province)

### Creating trust index
# AmericasBarometer asks many questions about a respondent's trust of various
# political institutions in their country, but today we are interested in their
# overall "trust" of the state they live under. To better capture overall 
# political trust, we'll be creating a trust index below
data <- data |> 
  mutate(
    across(starts_with("trust_"), ~ as.numeric(.x)),
    across(starts_with("trust_"), ~ (.x - 1) / 6)
  ) |>
  mutate(
    indexed_trust = rowMeans(pick(starts_with("trust_")), na.rm = TRUE)
  ) |> 
  select(
    country, province, asked_bribe, indexed_trust, age, gender, educ, income,
    religion_important,follow_news, soc_media_politics, -starts_with("trust_")
    ) |> 
  filter(complete.cases(
      educ, gender, income, religion_important, follow_news,
      soc_media_politics, asked_bribe, indexed_trust
      ))

### Task 1: 
# Using a naïve difference-in-means estimator, calculate the association between
# being asked to give a bribe to a government employee on your composite trust
# of the government. Output a tidy table with the point estimate, std. error, 
# the "treatment" labeled as "Asked Bribe". Interpret the association in a
# single sentence

# Because we are going to be working with the same regression formula, I've 
# specified the model here.
reg_form <- as.formula("indexed_trust ~ asked_bribe + age + educ + gender + income + religion_important + follow_news + soc_media_politics")

# Note with the matching packages that the formula to perform matching differs 
# from the regression formula
match_form <- as.formula(
  "asked_bribe ~ age + educ + gender + income + religion_important + follow_news + soc_media_politics"
)

# Running the base model
reg1 <- lm(reg_form, data = data)

# Creating the table
table <- modelsummary(
  reg1,
  title = "Association Between Being Asked for a Bribe and Trust",
  coef_map = c(
    "asked_bribe" = "Asked Bribe",
    "(Intercept)" = "Intercept"
  ),
  coef_omit = "age|educ|gender|income|religion_important|follow_news|soc_media_politics",
  estimate = "{estimate}{stars}",
  statistic = "({std.error})",
  gof_map = c("nobs", "adj.r.squared"),
  output = "kableExtra",
  notes = "Trust is a compositite index scaled to 0-1."
)

##### Checking Balance and Propensities ########################################
### Task 2:
# Check the imbalance between "treated" and "untreated" respondents using 
# matchit(). Print your output. Which covariate has the greatest absolute 
# standardized mean difference between groups?
imbalance <- matchit(match_form, data = data, method = NULL, distance = "glm")
summary(imbalance) # Looks like it is gender

### Note: you can create the propensity scores different ways:
# (i) a glm regression with a binomial (logit) distribution
# (ii) with the matchIt package

### Task 2: 
# Create a vector of respondents' propensity scores using the glm function
# and a binomial distribution. Save the scores as a separate vector, using the
# fitted values outputted from the regression.
make_prop_score  <- glm(match_form, family = binomial, data = data)

pscores_manual <- make_prop_score$fitted

### Task 3: 
# Create propensity scores using the matchit package. Be sure to select "glm"
# for the distance argument. Ignore the method argument for now. Extract the 
# propensity scores from the matchit object.
match_propensity <- matchit(match_form, data = data, method = "nearest", distance = "glm")

# Extracting the scores from the matchit object
pscores_auto <- match_propensity[[10]]

### Task 4:
# Compare the values by taking the correlation coefficient of the two objects.
cor(pscores_auto, pscores_manual) # Perfect correlation!

##### Matching Methods #########################################################
### Task 5:
# Using a euclidean distance matching procedure, estimate the ATT using the same
# regression formula from above.
match_euclid <- matchit(
  match_form, data = data, method = "nearest", distance = "euclidean"
)

### Task 6:
# Using a mahalanobis distance matching procedure, estimate the ATT using the 
# same regression formula from above. Use nearest neighbor matching.
match_mahalanobis <- matchit(
  match_form, data = data, method = "nearest", distance = "mahalanobis"
)

### Task 7: 
# Using a genetic matching method, estimate the ATT using the same regression
# formula from above. Use glm for distance and link for logit
parallel::clusterEvalQ(cl, { library(MatchIt) })

match_genetic <- matchit(
  formula  = match_form,
  data     = data,
  method   = "genetic",
  distance = "glm",
  link     = "logit",
  cluster  = cl,
)

# Manual stopping of workers (needed with socket parallelization)
parallel::stopCluster(cl)

### Task 8:
# Using a caliper matching method, estimate the ATT using the same regression
# formula from above. Check method_genetic for method and distance specifications. 
# Assume caliper = 0.2, ratio = 1, replace = F, std.caliper = T and link = 
# linear.logit
match_caliper <- matchit(
  formula  = match_form,
  data     = data,
  method   = "nearest",
  distance = "glm",
  link     = "linear.logit",
  caliper  = 0.2,
)

##### Assessing Balance ########################################################
### Task 9:
# Which of the 5 matching methods produced the greatest reduction in standardized
# mean difference (distance closest to zero) between treated and control groups?
summary(match_euclid)
summary(match_mahalanobis)
summary(match_genetic)
summary(match_caliper)
summary(match_propensity)

# For me, the most precise matching estimator (in terms of reducing the
# standardized mean difference the most) was the genetic matching estimator

### Task 10:
# Now let's practice visualizing the balance. Use the plot 
# function and plot the summary(). Note which matching method produced matched
# differences that still fall above the dashed 0.05 line.
plot(summary(match_propensity))
plot(summary(match_euclid))
plot(summary(match_mahalanobis))
plot(summary(match_genetic))
plot(summary(match_caliper))

# For me, the euclidean distance matching performed the worst, as it was the
# only method where the absolute standardized mean difference did not fall below
# 0.05 for all covariates

### Task 11:
# Let's turn to an alternative method of checking covariate balance, the 
# Kolmogorov-Smirnov (KS) Test. Using cobalt::love.plot where stats = "ks", 
# visualize the KS Test and state which matching method (i) on average had the
# greatest reduction of values for the test and (ii) which test had the absolute
# largest reduction for a single covariate
cobalt::love.plot(
  x = match_propensity,
  stats = "ks",
  abs = T
)

cobalt::love.plot(
  x = match_euclid,
  stats = "ks",
  abs = T
)

cobalt::love.plot(
  x = match_mahalanobis,
  stats = "ks",
  abs = T
)

cobalt::love.plot(
  x = match_genetic,
  stats = "ks",
  abs = T
)

cobalt::love.plot(
  x = match_caliper,
  stats = "ks",
  abs = T
)

##### Matching regressions #####################################################
### Task 12:
# For each of the matching objects we've created (there should be 5), estimate
# the ATT for the relationship between being asked to pay a bribe to a govt. 
# official and your composite trust index score. Note that the previous task
# only created matched objects, it did not run a regression
data_propensity <- match.data(match_propensity)
data_euclid <- match.data(match_euclid)
data_mahalanobis <- match.data(match_mahalanobis)
data_genetic <- match.data(match_genetic)
data_caliper <- match.data(match_caliper)

reg_propensity <- lm(reg_form, data = data_propensity, weights = weights)
reg_euclid <- lm(reg_form, data = data_euclid, weights = weights)
reg_mahalanobis <- lm(reg_form, data = data_mahalanobis, weights = weights)
reg_genetic <- lm(reg_form, data = data_genetic, weights = weights)
reg_caliper <- lm(reg_form, data = data_caliper, weights = weights)

### Task 13:
# Now output the results of these regressions into a tidy table using the
# "skeleton" code below. Make sure to change variable names as is relevant to
# your own code here (i.e., my model columns may be different from yours)
models <- list(
  "No Matching" = reg1,
  "Propensity" = reg_propensity,
  "Euclidean" = reg_euclid,
  "Mahalanobis" = reg_mahalanobis,
  "Genetic" = reg_genetic,
  "Caliper" = reg_caliper
)

# Printing the table
table_2 <- modelsummary(
  models,
  title = "Association Between Being Asked for a Bribe and Trust",
  coef_map = c(
    "asked_bribe" = "Asked Bribe",
    "(Intercept)" = "Intercept"
  ),
  coef_omit = "age|educ|gender|income|religion_important|follow_news|soc_media_politics",
  estimate = "{estimate}{stars}",
  statistic = "({std.error})",
  gof_map = c("nobs", "adj.r.squared"),
  output = "kableExtra",
  notes = c(
    "Trust is a composite index scaled to 0-1."
  )
)

# The table
table_2

###### Sensitivity Analysis ####################################################
### Task 14: 
# Check how sensitive your results are from the models you ran above using the
# rbounds package. You will need to extract the estimates from your models
# and then run psens() in rbounds. Which matching method produces the most
# sensitive results?

# Making a list of match_objects
match_objects <- list(
  Propensity  = match_propensity,
  Euclidean   = match_euclid,
  Mahalanobis = match_mahalanobis,
  Genetic     = match_genetic,
  Caliper     = match_caliper
)

# Function to run psens across models
psens_table <- function(m, model_name, Gamma = 1, GammaInc = 0.1) {
  dat <- match.data(m) |>
    arrange(subclass)
  res <- psens(
    x = dat$indexed_trust[dat$asked_bribe == 0],
    y = dat$indexed_trust[dat$asked_bribe == 1],
    Gamma = Gamma,
    GammaInc = GammaInc
  )
  res$bounds |>
    mutate(Model = model_name) |>
    select(Model, everything())
}

# Building combined table with all matched models
sensitivity_table <-
  imap_dfr(match_objects, ~ psens_table(.x, .y, Gamma = 2, GammaInc = 0.1))

# Outputting table, it looks like Euclidean matching produces the most sensitive
# results.
sensitivity_table |>
  knitr::kable(
    digits = 4,
    caption = "Rosenbaum Sensitivity Analysis Across Matching Methods"
  ) |>
  kableExtra::kable_minimal(font_size = 18)
################################################################################