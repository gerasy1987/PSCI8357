################################################################################
################# This R Script Does the Following: ############################
### Uses built-in R data from `airquality` to demonstrate how to use different
### missing data imputation methods.
################################################################################
### Load packages, and load data
# airquality data built-into R
data("airquality")
df <- airquality
rm(airquality)

# Load packages
if(!require(mice)) install.packages("mice") # common multiple imputation package
if(!require(naniar)) install.packages("naniar") # missingness visualization

##### Pre-imputation checks ####################################################
### How much data is missing?
colSums(is.na(df))

### Visualizing the missingness
naniar::vis_miss(df)

### Baseline model
mod <- Ozone ~ Solar.R + Wind + Temp

##### Imputations ##############################################################
### Listwise deletion
# Removing rows with NAs
listwise <- na.omit(df[, c("Ozone", "Solar.R", "Wind", "Temp")])

# Checks (we lost 27% of original sample)
nrow(df)
nrow(listwise)

# Regression model
reg_list <- lm(mod, data = listwise)

# Output 
summary(reg_list)

### Single mean imputation
# Creating df object to which we are performing single mean imputation
mean_imp <- df

# Mean imputing ozone and solar.r
mean_imp$Ozone <- ifelse(
  is.na(mean_imp$Ozone),
  mean(mean_imp$Ozone, na.rm = T),
  mean_imp$Ozone
)

mean_imp$Solar.R <- ifelse(
  is.na(mean_imp$Solar.R),
  mean(mean_imp$Solar.R, na.rm = T),
  mean_imp$Solar.R
)

# Checking if this was successful (yes)
colSums(is.na(mean_imp[, c("Ozone", "Solar.R", "Wind", "Temp")]))

# Running regressions
reg_mean <- lm(mod, data = mean_imp)
summary(reg_mean)
summary(reg_list)

### Mice
vars <- c("Ozone", "Solar.R", "Wind", "Temp")
df_mi <- df[, vars]

# Inspect mice setup
ini <- mice(df_mi, maxit = 0)
ini$method
ini$predictorMatrix

# Run multiple imputation with predictor mean matching
set.seed(02272026)
imp <- mice(df_mi, m = 10, method = "pmm", maxit = 20, printFlag = FALSE)

# Fit model across imputations and pool
fits <- with(imp, lm(Ozone ~ Solar.R + Wind + Temp))
pooled <- pool(fits)

summary(pooled)

##### Comparing Results ########################################################
### Function to extract coefs from regression models
get_coefs <- function(mod) {
  s <- summary(mod)
  out <- data.frame(
    term = rownames(s$coefficients),
    estimate = s$coefficients[, 1],
    se = s$coefficients[, 2],
    row.names = NULL
  )
  out
}

res_listwise <- transform(get_coefs(reg_list), method = "Listwise deletion")
res_meanimp  <- transform(get_coefs(reg_mean),  method = "Mean imputation")

# mice pooled is already a summary table
res_mice <- summary(pooled)[, c("term", "estimate", "std.error")]
names(res_mice) <- c("term", "estimate", "se")
res_mice$method <- "Multiple imputation (mice)"

results <- rbind(res_listwise, res_meanimp, res_mice)

# Display nicely
results[order(results$term, results$method), ]

# Plots
ggplot(subset(results, term != "(Intercept)"),
       aes(x = method, y = estimate)) +
  geom_point() +
  facet_wrap(~ term, scales = "free_y") +
  theme(axis.text.x = element_text(angle = 30, hjust = 1))

ggplot(subset(results, term != "(Intercept)"),
       aes(x = method, y = se)) +
  geom_point() +
  facet_wrap(~ term, scales = "free_y") +
  theme(axis.text.x = element_text(angle = 30, hjust = 1))
################################################################################