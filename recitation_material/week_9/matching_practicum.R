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
setwd("")

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


### Parallelization
# Some of the code will take too long without running it in parallel, so let's 
# set up the prep here

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
    across(starts_with("trust_"), ~ (.x - 1) / 6) # Standardizing to a [0,1] space
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
# the "treatment" labeled as "Asked Bribe", & no covariates listed on the table.
# Exclude all gof_map outputs except R^2 and No. obs. Interpret the association 
# in a single sentence. Use the skeleton table code below and make changes as
# needed. Hint: the modelsummary webpage is very helpful here.

# The table
table_1 <- modelsummary(
  reg1,
  title = "",
  coef_map = c(
    "asked_bribe" = "",
    "(Intercept)" = ""
  ),
  coef_omit = "",
  estimate = "",
  statistic = "",
  gof_map = "",
  output = "kableExtra",
  notes = ""
)

##### Checking Balance and Propensities ########################################
### Task 2:
# Check the imbalance between "treated" and "untreated" respondents using 
# matchit(). Print your output. Which covariate has the greatest absolute 
# standardized mean difference between groups? Hint, method = NULL.


### Note: you can create the propensity scores different ways:
# (i) a glm regression with a binomial (logit) distribution
# (ii) with the matchIt package

### Task 2: 
# Create a vector of respondents' propensity scores using the glm function
# and a binomial distribution. Save the scores as a separate vector, using the
# fitted values outputted from the regression.


### Task 3: 
# Create propensity scores using the matchit package. Be sure to select "glm"
# for the distance argument. Ignore the method argument for now. Extract the 
# propensity scores from the matchit object.


### Task 4:
# Compare the values by taking the correlation coefficient of the two objects.


##### Matching Methods #########################################################
### Task 5:
# Using a euclidean distance matching procedure, perform matching.


### Task 6:
# Using a mahalanobis distance matching procedure, perform matching.
# Use nearest neighbor matching.


### Task 7: 
# Using a genetic matching method, perform matching. Use glm for distance 
# and link for logit. Note: Wrap the code chunk in the parallel wrapper as shone
# below and include cluster = cl as one of the arguments

parallel::clusterEvalQ(cl, { library(MatchIt) })



# Manual stopping of workers (needed with socket parallelization process)
parallel::stopCluster(cl)

### Task 8:
# Using a caliper matching method, estimate the ATT using the same regression
# formula from above. Check method_genetic for method and distance specifications. 
# Assume caliper = 0.2, ratio = 1, replace = F, std.caliper = T and link = 
# linear.logit


##### Assessing Balance ########################################################
### Task 9:
# Which of the 5 matching methods produced the greatest reduction in standardized
# mean difference (distance closest to zero) between treated and control groups?


### Task 10:
# Now let's practice visualizing the balance. Use the plot 
# function and plot the summary(). Note which matching method produced matched
# differences that still fall above the dashed 0.05 line.


### Task 11:
# Let's turn to an alternative method of checking covariate balance, the 
# Kolmogorov-Smirnov (KS) Test. Using cobalt::love.plot where stats = "ks", 
# visualize the KS Test and state which matching method (i) on average had the
# greatest reduction of values for the test and (ii) which test had the absolute
# largest reduction for a single covariate


##### Matching regressions #####################################################
### Task 12:
# For each of the matching objects we've created (there should be 5), estimate
# the ATT for the relationship between being asked to pay a bribe to a govt. 
# official and your composite trust index score. Note that the previous task
# only created matched objects, it did not run a regression


### Task 13:
# Now output the results of these regressions (and the no-matching regression) 
# into a tidy table using the "skeleton" code below. Make sure to change 
# variable names as is relevant to your own code here. Use the same code from 
# above, just be sure to name the models (Hint: define the model names in a list
# outside of the table object).


###### Sensitivity Analysis ####################################################
### Task 14: 
# Check how sensitive your results are from the models you ran above using the
# rbounds package. You will need to extract the estimates from your models
# and then run psens() in rbounds. Use the provided function and table code in 
# the interest of time. Any part of the function/code with Z listed must be
# changed to a proper value! Be sure to create a list for match_objects as well.

# Function to run psens across models
psens_table <- function(m, model_name, Gamma = Z, GammaInc = Z) {
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
  imap_dfr(match_objects, ~ psens_table(.x, .y, Gamma = Z, GammaInc = Z))

# Outputting table, it looks like xxx is the best.
sensitivity_table |>
  knitr::kable(
    digits = 4,
    caption = "Rosenbaum Sensitivity Analysis Across Matching Methods"
  ) |>
  kableExtra::kable_minimal(font_size = 18)



################################################################################