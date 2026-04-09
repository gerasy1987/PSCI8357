################################################################################
################# This R Script Does the Following: ############################
### Provides students in the recitation period with a chance to practice
### coding in R with a regression discontinuity design. All coding uses the
### same motivating question, what is the effect of narrowly winning a U.S.
### Senate election on the Democratic vote share in the next election?
################################################################################
### Load packages, data, and set working directory
# Setting the working directory
# If you do not know the directory you are working out of, use getwd() first
setwd("")

# Packages
if (!require(tidyverse)) install.packages("tidyverse")
if (!require(rdrobust)) install.packages("rdrobust")
if (!require(rddensity)) install.packages("rddensity")
if (!require(modelsummary)) install.packages("modelsummary")
if (!require(kableExtra)) install.packages("kableExtra")

options(scipen = 999)

# Load the built-in Senate election data from the rdrobust package and name the
# loaded object `data`
data("rdrobust_RDsenate", package = "rdrobust")
data <- rdrobust_RDsenate
rm(rdrobust_RDsenate)

##### Examining the data #######################################################
### Subsetting and renaming
# This code below subsets the data to only the variables needed for our
# analyses today, run it and ask if there are parts of the code that you do not
# understand why or how I wrote the specific code chunk
data <- data |>
  select(
    margin, # Democratic margin of victory in the previous election
    vote # Democratic vote share in the next election
  ) |>
  rename(
    dem_margin_last = margin,
    dem_vote_share_next = vote
  ) |>
  mutate(
    dem_incumbent = if_else(dem_margin_last >= 0, 1, 0),
    abs_margin = abs(dem_margin_last)
  ) |>
  filter(complete.cases(dem_margin_last, dem_vote_share_next))

### Task 1:
# Before estimating anything, examine the running variable and the outcome.
# Use summary() and then calculate the proportion of observations where
# Democrats barely won the previous election (dem_incumbent == 1).


### Task 2:
# Using a naïve difference-in-means estimator, calculate the association
# between Democratic incumbency and the Democratic vote share in the next
# election. Output a tidy table with the point estimate and std. error, the
# "treatment" labeled as "Democratic Incumbent", and no other coefficients
# listed in the table. Exclude all gof_map outputs except R^2 and No. obs.

# The table
table_1 <- modelsummary(
  reg_naive,
  title = "Association Between Incumbency and Vote Share",
  coef_map = c(
    "dem_incumbent" = "Democratic Incumbent",
    "(Intercept)" = "Intercept"
  ),
  coef_omit = "Intercept",
  estimate = "{estimate}{stars}",
  statistic = "({std.error})",
  gof_map = c("nobs", "adj.r.squared"),
  output = "kableExtra",
  notes = "Outcome is Democratic vote share in the next election."
)

##### Local Linear RDD by Hand #################################################
### Task 3:
# Create a local sample that keeps only observations within 10 percentage
# points of the cutoff. Save that number as an object called h_manual.


### Task 4:
# Estimate a local linear regression with a common slope on both sides of the
# cutoff using lm(). Use the local sample you just created. How does the
# incumbency estimate compare to the naïve estimate?


### Task 5:
# Estimate a local linear regression that allows different slopes on each side
# of the cutoff. Hint: use an interaction between dem_incumbent and
# dem_margin_last. Which coefficient now captures the jump at the cutoff?


### Task 6:
# Create triangular kernel weights by hand for the local sample. Then estimate
# a weighted local linear regression using the same interaction specification as
# Task 5. Why should units closest to the cutoff receive the largest weights?


##### Visualizing the Design ###################################################
### Task 7:
# Use rdplot() to visualize the regression discontinuity. Set the cutoff to 0,
# use a first-order polynomial, and choose informative axis labels.


##### Estimating with rdrobust #################################################
### Task 8:
# Estimate the sharp RDD using rdrobust() with a triangular kernel, p = 1,
# cutoff c = 0, and the same manual bandwidth from above. Print the output.
# Compare the conventional rdrobust estimate to your weighted local linear
# regression.


### Task 9:
# Now estimate the RDD again using rdrobust() with the MSE-optimal bandwidth
# choice. Save the object as est_rd_auto and inspect the selected bandwidth.


### Task 10:
# Compare how the robust RD estimate changes across bandwidths 5, 10, 15, 20,
# 25, and the optimal bandwidth from Task 10. Build a data frame with the
# estimate and standard error for each bandwidth, then make a plot with point
# estimates and 95% confidence intervals.


##### Robustness Checks ########################################################
### Task 11:
# Implement placebo cutoff tests. Use the median value of dem_margin_last among
# observations below 0 as one placebo cutoff and the median value among
# observations above or equal to 0 as the second placebo cutoff. For each test,
# only keep observations on the same side of the true cutoff.


### Task 12:
# Estimate a donut-hole robustness check by removing elections within 2
# percentage points of the true cutoff and re-estimating the RDD with the same
# manual bandwidth. Does the point estimate change very much?


### Task 13:
# Use the rddensity package to test for manipulation of the running variable at
# the cutoff. Print the summary output and make the corresponding density plot.
# What does this suggest about sorting around the threshold?


################################################################################