################################################################################
################# This R Script Does the Following: ############################
### Provides students in the recitation period with a chance to practice
### coding in R with an instrumental variables design. All coding uses the same
### motivating question, what is the return to an additional year of schooling
### on hourly wages, and how do our conclusions change once we instrument for
### schooling with proximity to college?
################################################################################
### Load packages, data, and set working directory
# Setting the working directory
# If you do not know the directory you are working out of, use getwd() first
setwd("")

# Packages
if (!require(tidyverse)) install.packages("tidyverse")
if (!require(ivreg)) install.packages("ivreg")
if (!require(modelsummary)) install.packages("modelsummary")
if (!require(kableExtra)) install.packages("kableExtra")
if (!require(broom)) install.packages("broom")
if (!require(lmtest)) install.packages("lmtest")
if (!require(sandwich)) install.packages("sandwich")

options(scipen = 999)

# Load data and name the loaded object `data`


##### Examining the data #######################################################
### Subsetting
# This code below will subset the code to only the relevant variables for our
# analyses today, run it and ask if there are parts of the code that you don't
# understand why or how I wrote the specific code chunk
data <- data |>
  dplyr::select(
    wage, # hourly wage in 1976, measured in cents
    education, # completed years of schooling
    experience, # years of labor market experience
    ethnicity, # whether respondent is African-American
    smsa, # whether respondent lives in a metropolitan area
    south, # whether respondent lives in the U.S. South
    nearcollege4, # whether respondent grew up near a 4-year college
    nearcollege2, # whether respondent grew up near a 2-year college
    feducation # father's years of schooling
  ) |>
  dplyr::mutate(
    log_wage = log(wage),
    nearcollege4 = if_else(nearcollege4 %in% c("public", "private"), 1, 0),
    nearcollege2 = if_else(nearcollege2 == "yes", 1, 0)
  ) |>
  tidyr::drop_na()

### Task 1:
# Estimate a naïve OLS model of logged wages on years of schooling and the
# controls listed below. Output a tidy table with robust (HC1) standard errors,
# the treatment labeled as "Education (Years)", and no control variables listed
# on the table. Exclude all gof_map outputs except R^2 and No. obs. Interpret
# the association in a single sentence.

# The main formulas we will use today
ols_form <- as.formula(
  "log_wage ~ education + experience + ethnicity + smsa + south + feducation"
)

iv_form <- as.formula(
  "log_wage ~ education + experience + ethnicity + smsa + south + feducation |
   nearcollege4 + experience + ethnicity + smsa + south + feducation"
)

iv_form_overid <- as.formula(
  "log_wage ~ education + experience + ethnicity + smsa + south + feducation |
   nearcollege4 + nearcollege2 + experience + ethnicity + smsa + south + feducation"
)

# Running the OLS model
ols_mod <- "INSERT HERE"

# The table
table_1 <- modelsummary(
  ols_mod,
  title = "",
  coef_map = c(
    "education" = "",
    "(Intercept)" = ""
  ),
  coef_omit = "",
  estimate = "",
  statistic = "",
  gof_map = "",
  vcov = "",
  output = "kableExtra",
  notes = "Outcome is logged hourly wages (in cents) in 1976."
)

##### Instrument Relevance ####################################################
### Task 2:
# Estimate the first-stage regression where education is the dependent variable
# and nearcollege4 is the excluded instrument. Print the model summary. Is the
# sign on nearcollege4 what you would expect if college proximity raises
# schooling attainment?



### Task 3:
# Extract the first-stage fitted values from the regression above and save them
# as a new vector called `schooling_hat`.



### Task 4:
# Visualize instrument relevance by plotting average years of schooling by
# nearcollege4 status.

data |>
  dplyr::group_by(D) |>
  dplyr::summarise(mean_Y = mean(Y), .groups = "drop") |>
  ggplot(aes(x = X, y = Y, fill = D)) +
  geom_col(width = 0.55, show.legend = FALSE) +
  geom_text(aes(label = round(mean_Y, 2)), vjust = 1.5, size = 5) +
  scale_fill_gradient(low = "grey80", high = "grey40") +
  labs(
    title = "Average Schooling by 4-Year College Proximity",
    x = "Grew Up Near a 4-Year College",
    y = "Average Years of Schooling"
  ) +
  theme_minimal(base_size = 15)

##### IV Estimation ############################################################
### Task 5:
# Estimate the 2SLS model using ivreg() and the formula object above. After this,
# print the model summary with diagnostics = TRUE. Which of the three diagnostic 
# tests reported concern (i) weak instruments and (ii) endogeneity of schooling?



### Task 6:
# Create a tidy table comparing the OLS and IV estimates. Label the schooling 
# coefficient "Education (Years)", and omit the controls from the table.

models <- list(
  "OLS" = insert,
  "IV" = insert
)

table_2 <- modelsummary(
  models,
  title = "Returns to Schooling: OLS and IV Estimates",
  coef_map = c(
    "education" = "",
    "(Intercept)" = ""
  ),
  coef_omit = "",
  estimate = "",
  statistic = "",
  gof_map = "",
  vcov = "HC2",
  output = "kableExtra",
  notes = "Outcome is logged hourly wages in 1976."
)

##### Robustness Checks ########################################################
### Task 7:
# Estimate an alternative IV model that uses both nearcollege4 and nearcollege2
# as excluded instruments. Print the summary with diagnostics = TRUE. Does the
# overidentification test give you evidence against the joint validity of the
# instruments?



### Task 8:
# Compare the education coefficient across the OLS model, the single-instrument
# IV model, and the two-instrument IV model in a coefficient plot. Use 95%
# confidence intervals and robust (HC1) standard errors.
coef_plot_data <- list(
  "OLS" = ols_mod,
  "IV: 4-Year College" = iv_mod,
  "IV: 2-Year + 4-Year College" = iv_mod_overid
) |>
  purrr::imap_dfr(\(model, model_name) {
    robust_vcov <- sandwich::vcovHC(model, type = "HC1")
    
    broom::tidy(model, conf.int = FALSE) |>
      dplyr::filter(term == "education") |>
      dplyr::mutate(
        model = model_name,
        std.error = sqrt(diag(robust_vcov))[term],
        conf_low = estimate - 1.96 * std.error,
        conf_high = estimate + 1.96 * std.error
      )
  })

ggplot(coef_plot_data, aes(x = model, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_pointrange(aes(ymin = conf_low, ymax = conf_high), size = 0.6) +
  labs(
    title = "Estimated Return to Schooling Across Specifications",
    x = "",
    y = "Coefficient on Education"
  ) +
  theme_minimal(base_size = 14)

### Task 9:
# Create a reduced-form regression where log_wage is the dependent variable and
# nearcollege4 is the key explanatory variable, holding the same controls
# constant. Output the coefficient on nearcollege4. How would you substantively
# interpret this coefficient?



################################################################################