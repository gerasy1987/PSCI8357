################################################################################
################# This R Script Does the Following: ############################
### Replicates the main analysis from Breznau et al. 2022 article in PNAS.
### Specifically, it tests the association between immigration rates and
### support for government service delivery cross-nationally.
################################################################################
### Set working directory, load packages, and load data
# Working Directory

# NOTE: set the working to YOUR correct pathway
setwd("INPUT YOUR PATHWAY")
options(scipen = 999)

# Re-run if you are installing a package for the first time
if (!require(tidyverse)) install.packages("tidyverse")
if (!require(stargazer)) install.packages("stargazer")
# Or run this after: pacman::p_load(tidyverse)

# Load data:
data <- read.csv("replication_data.csv")

# TASK: Conduct an empirical analysis that tests whether there is a significant
# association between a country's immigration rates and popular support for 
# government spending on service delivery in sectors like old-age pensions,
# healthcare, housing, etc.

##### Cleaning #################################################################
### Missing Data
# Some columns in this dataframe are missing data. How will you handle units
# that do have some missing data?

# INSERT ANY CLEANING (IF YOU DO INCLUDE EXTRA CLEANING) HERE

### Your DV
# Are you creating an index of government service delivery policies? Or are you 
# using one of these variables? 

# INSERT ANY RELEVANT CODE (AS NEEDED) HERE

##### Analysis #################################################################
### Regress immigration rate on support for xxx. Consider the following:
# 1) Are you including any control(s)?
# 2) Are you maintaining the panel or collapsing it?
# 3) Are you including fixed effects?
# 4) Are you clustering your std. errors? At what level?

# INSERT REGRESSION CODE HERE

# In your regression table, you should have the following:
# 1) A clearly printed table title
# 2) Clearly printed column label(s) / model name(s)
# 3) Clearly printed covariate labels (don't keep the variable name)
# 4) In the bottom of the table, print the number of observations, your R^2,
# if you used FEs. Do not include information like the BIC.
# 5) In the table notes, include any information you believe to be relevant to 
# interpreting the table. Also include the legend for your p-value stars

# INSERT TABLE CODE HERE

################################################################################