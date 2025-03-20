################################################################################
################# This R Script Does the Following: ############################
### Provides a basic implementation of the DiD package in R from Callaway and
### Sant'Anna (2021). This is one of many packages that can implement DiD in R
### that recovers the ATT under certain assumptions
################################################################################
### Set working directory, load packages, and load data
# Working Directory
setwd("/Users/alexdean/Documents/Vanderbilt/Service/Spring 2025/Recitation/week_11")
options(scipen = 999)
set.seed(37212)

# Packages
if (!require(tidyverse)) install.packages("tidyverse")
if (!require(did)) install.packages("did")
if (!require(DIDmultiplegtDYN)) install.packages("DIDmultiplegtDYN")
if (!require(HonestDiD)) install.packages("HonestDiD")
if (!require(PanelMatch)) install.packages("PanelMatch")

pacman::p_load(tidyverse, plm, DIDmultiplegtDYN, HonestDiD)

################################################################################
### Creating panel data that we can use to set up DiD estimators
# Creating no. units and no. periods
num_units <- 1000
num_periods <- 20

# Creating base panel structure
panel_data <- expand.grid(unit = 1:num_units, time = 1:num_periods)

### First, we need to create a panel with a once treated, always treated panel
# Assigning a random period of first treatment (between period 2 and num_periods)
treatment_start <- sample(2:num_periods, num_units, replace = TRUE)

# Create treatment variable (1 if treated, remains treated)
panel_data <- panel_data |> 
  mutate(d_always = ifelse(time >= treatment_start[unit], 1, 0))

### Second, we need to create a panel where units go in and out of treatment
# Each unit has a 20% probability of being treated in each period
panel_data <- panel_data |> 
  mutate(d_one_period = rbinom(n(), 1, 0.3))

### Generate Covariates (drawing i.i.d. from normal)
panel_data <- panel_data |> 
  mutate(
    a = rnorm(n(), mean = 50, sd = 10), 
    b = rbinom(n(), 1, 0.5),             
    c = runif(n(), min = 0, max = 100)
  )

### Generating outcome variables with positive treatment effect
true <- 5  # Making a positive treatment effect

# Making outcome vars
panel_data <- panel_data |> 
  mutate(
    y_always = 100 + 2*a + 3*b + 0.5*c + true * d_always + rnorm(n(), 0, 5),
    y_one_period = 100 + 2*a + 3*b + 0.5*c + true * d_one_period + rnorm(n(), 0, 5)
  )

panel_data <- panel_data |> 
  group_by(unit) |> 
  mutate(G = ifelse(any(d_always == 1), min(time[d_always == 1], na.rm = TRUE), 0)) |> 
  ungroup()


################################################################################
### Callaway and Sant'Anna
model_1 <- att_gt(
  yname = "y_always", # Dependent variable
  gname = "G", # First period treated (0 if never-treated)
  tname = "time", # Time variable
  xformla = ~ a + b + c, # Covariates (none in this example)
  data = panel_data, # Data
  est_method = "dr", # Doubly robust estimation
  control_group = "notyettreated", # Comparison group
  anticipation = 0, # Number of leads to account for anticipation effects
  bstrap = TRUE, # Use bootstrapping for SEs
  biters = 1000, # Number of bootstrap iterations
  print_details = TRUE, # Print model details
  clustervars = "unit" # Clustered standard errors
)

# Visualizing output
ggdid(model_1)

# Summarizing output
summary(model_1)

# Event-study output
estudy <- aggte(model_1, type = "dynamic")

### De Chaisemartin and d'Haultfœuille 
# Always treated
model_2 <- did_multiplegt_dyn(
    df = panel_data, # data frame
    outcome = "y_always", # outcome measure
    group = "unit", # group/unit (like municipality)
    time = "time", # tmeporal variable
    treatment = "d_always", # outcome variable
    effects = 5, 
    placebo = 5, # no. placebo estimators to be computed
    controls = c("a", "b", "c"), # controls to be included
    cluster = 'unit' # level you want to cluster your std. errors at
  )

# In and out of teratment
model_3 <- did_multiplegt_dyn(
  df = panel_data,
  outcome = "y_one_period",
  group = "unit",
  time = "time",
  treatment = "d_one_period",
  effects = 5,
  placebo = 5,
  controls = c("a", "b", "c"),
  cluster = 'unit'
)

# Viewing the plots
model_2$plot
model_3$plot

### Rambachan and Roth 
# Testing of parallel trends assumption using sensitivity analysis with the
# construction of a nuisance parameter to determine how sensitive results are
# to parallel trends violations

# First need to extract certain parameters from the event study from the 
# Callaway and Sant'Anna estimator
estudy <- aggte(model_1, type = "dynamic")
betahat <- estudy$att.egt
sigma <- estudy$V_egt 
numPrePeriods <- sum(estudy$egt < 0)   # Pre-treatment periods
numPostPeriods <- sum(estudy$egt >= 0) # Post-treatment periods

# Running the sensitivity analysis function!
sensitivity_results <- createSensitivityResults(
  betahat = betahat,
  sigma = sigma,
  numPrePeriods = numPrePeriods,
  numPostPeriods = numPostPeriods,
  alpha = 0.05
)

# Create Sensitivity Plot
sensitivity_plot <- createSensitivityPlot(
  robustResults = sensitivity_results,
  originalResults = constructOriginalCS(
    betahat = betahat,
    sigma = sigma,
    numPrePeriods = numPrePeriods,
    numPostPeriods = numPostPeriods,
    alpha = 0.05
  )
)
