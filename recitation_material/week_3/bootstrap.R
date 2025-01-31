################################################################################
################# This R Script Does the Following: ############################
### Provides examples of the uses of bootstrapping for small sample sizes and
### autocorrelated std errors
################################################################################
### Load packages
options(scipen = 999)

if (!require(tidyverse)) install.packages("tidyverse")
if (!require(boot)) install.packages("boot")
if (!require(parallel)) install.packages("parallel")
if (!require(pbapply)) install.packages("pbapply")
if (!require(lmtest)) install.packages("lmtest")
if (!require(sandwich)) install.packages("sandwich")
if (!require(tidyverse)) install.packages("tidyverse")
if (!require(tidyverse)) install.packages("tidyverse")

pacman::p_load(tidyverse, boot, parallel, pbapply, lmtest, sandwich)

### Set set for reproducability
set.seed(123456)

### Parallel setup
num_cores <- detectCores() - 1  # Use all but one core

######### Small Sample #########################################################
### Simulating a non-normal small dataset
n <- 20  # Small sample size
true_mean <- 5  # True population mean
data_sample <- rexp(n, rate = 1/true_mean)  # Exponential distribution

# Let's plot this and see what it looks like
hist(data_sample, breaks = 10, main = "Original Skewed Sample", xlab = "Values", col = "lightblue")

### Bootstrapping function and data generation
# Making a function for bootstrapping the mean
boot_mean <- function(data, indices) {
  return(mean(data[indices]))  # Compute mean on resampled data
}

### Creating a vector of integers as the resample R
resample_sequence <- c(50, 100, 500, 1000, 5000)

### Bootstrap function
perform_bootstrap <- function(R, data) {
  boot_res <- boot(data = data, statistic = boot_mean, R = R)
  
  # Using tryCatch to avoid errors in case boot.ci fails
  boot_ci <- tryCatch(
    boot.ci(boot_res, type = c("perc", "bca")),
    error = function(e) NULL  # Return NULL if boot.ci fails
  )
  
  return(list(bootstrap_results = boot_res, confidence_intervals = boot_ci))
}

### Bootstrapping in parallel
bootstrap_outputs <- mclapply(resample_sequence, function(R) perform_bootstrap(R, data_sample), mc.cores = num_cores)

# Traditional Normal Approximation Confidence Interval (assuming normality)
normal_ci <- mean(data_sample) + c(-1.96, 1.96) * (sd(data_sample) / sqrt(n))

### Distribution plotting
par(mfrow = c(2, 3))  # Set up a grid layout for plots (2 rows, 3 columns)

# Plot the original skewed sample
hist(data_sample, breaks = 10, main = "Original Skewed Sample", xlab = "Values", col = "lightblue")

# Loop through each bootstrap result and plot the bootstrap distributions
for (i in seq_along(resample_sequence)) {
  boot_res <- bootstrap_outputs[[i]]$bootstrap_results
  hist(boot_res$t, main = paste("Bootstrap R =", resample_sequence[i]),
       xlab = "Sample Mean", col = "lightgreen", breaks = 20)
  
  # Add confidence intervals (only if boot.ci was successful)
  boot_ci <- bootstrap_outputs[[i]]$confidence_intervals
  if (!is.null(boot_ci)) {
    abline(v = boot_ci$percent[4:5], col = "red", lwd = 2, lty = 2)  # Bootstrapped CI
  }
  abline(v = normal_ci, col = "blue", lwd = 2, lty = 2)  # Normal CI
}

# Reset plotting layout
par(mfrow = c(1,1))

######### Autocorrelation ######################################################
### Define simulation parameters
N <- 500   # Number of panel units (e.g., countries, firms)
T <- 50   # Number of time periods
rho <- 0.85  # High autocorrelation coefficient in errors

### Creating a panel dataset
panel_data <- expand.grid(id = 1:N, time = 1:T) |> 
  mutate(
    x = rnorm(N * T, mean = 5, sd = 0.75),  # Random explanatory variable
    alpha = rnorm(N, mean = 0, sd = 1)[id],  # Unit fixed effects
    epsilon = rep(NA, N * T)  # Placeholder for autocorrelated errors
  )

# Defining sigma
sigma <- 4

### Ensure stationary AR(1) process by discarding transient dynamics
burn_in <- 50  # Number of initial values to discard
extended_T <- T + burn_in  # Total length of generated series

for (i in 1:N) {
  e <- numeric(extended_T)
  e[1] <- rnorm(1, mean = 0, sd = sigma)  # Initial error term
  for (t in 2:extended_T) {
    e[t] <- rho * e[t - 1] + rnorm(1, mean = 0, sd = sigma)  # AR(1) process
  }
  # Retain only the stationary portion
  panel_data$epsilon[panel_data$id == i] <- e[(burn_in + 1):extended_T]
}

### Generate dependent variable (panel regression model)
panel_data <- panel_data  |> 
  mutate(y = 2 + 0.25 * x + alpha + epsilon)

### 'Ole OLS
ols_model <- lm(y ~ x, data = panel_data)
summary(ols_model)

### Clustered standard errors
clustered_se <- coeftest(ols_model, vcov = vcovCL(ols_model, cluster = ~id))
print(clustered_se)

### Define the bootstrap function
wild_boot_fn <- function(data, multipliers) {
  # Computing residuals
  residuals <- residuals(ols_model)
  # Generating new y* values
  y_star <- fitted(ols_model) + residuals * multipliers
  # Fitting the new model with bootstrapped dependent variable
  boot_data <- data
  boot_data$y <- y_star
  
  boot_model <- lm(y ~ x, data = boot_data)
  return(coef(boot_model))
}

### Parallel processing setup
num_cores <- detectCores() - 1  # Use all but one core
cl <- makeCluster(num_cores, type = "PSOCK")

# Export necessary objects to worker nodes
clusterExport(cl, varlist = c("panel_data", "wild_boot_fn", "ols_model"))
clusterEvalQ(cl, library(dplyr))

### Wildbootstrapping function
B <- 5000  # Number of bootstrap replications

boot_results <- tryCatch({
  pblapply(1:B, function(i) {
    # Generate Rademacher multipliers {-1,1} randomly
    multipliers <- sample(c(-1, 1), size = nrow(panel_data), replace = TRUE)
    
    # Apply wild bootstrap function
    wild_boot_fn(panel_data, multipliers)
  }, cl = cl)
}, error = function(e) {
  stopCluster(cl)
  stop("Error in parallel execution: ", e$message)
})

### Potential troubleshooting
# Stop the cluster after computation
stopCluster(cl)

# Check to make sure bootstrapping worked
if (is.null(boot_results) || length(boot_results) < B) {
  stop("Bootstrapping failed. Check error logs for details.")
}

### Converting bootstrapped estimates to a matrix
boot_matrix <- do.call(rbind, boot_results)

### Obtaining wild bootstrap standard errors
wild_boot_se <- apply(boot_matrix, 2, sd)
names(wild_boot_se) <- names(coef(ols_model))

### Comparing standard errors
se_comparison <- data.frame(
  Estimate = coef(ols_model),
  OLS_SE = summary(ols_model)$coefficients[, "Std. Error"],
  Clustered_SE = clustered_se[, "Std. Error"],
  Wild_Boot_SE = wild_boot_se
)

print(se_comparison)
###############################################################################