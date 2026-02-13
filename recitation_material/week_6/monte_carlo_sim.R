################################################################################
################# This R Script Does the Following: ############################
### Provides a demonstration of the application of Monte Carlo simulatins in 
### empirical political science work
################################################################################
### Load packages and set seed
if (!require(fixest)) install.packages("fixest")
if (!require(tidyverse)) install.packages("tidyverse")

set.seed(02132026)

##### Setup ####################################################################
### Parameters
# First, we need to choose our paramenters for this simulation:
G <- 30 # Number of clusters (e.g., municipalities)
n <- 50 # Units per cluster (e.g., individuals)
R <- 1000 # Number of Monte Carlo simulations
alpha <- 0.05 # Significance level
beta <- 0.20 # True treatment effect (DiD effect size)
sigma <- 1.0 # Noise level (bigger = harder to detect effect)

# Also storing whether we reject H0 in each simulation
reject <- rep(FALSE, R)

##### Basic MC loop ############################################################
### For loop
for (r in 1:R) {
  
  # Creating the ids for each cluster and person
  cluster_id <- rep(1:G, each = n * 2) # Each cluster has n people in 2 periods
  person_id <- rep(1:(G * n), each = 2) # Each person appears twice (pre and post)
  post <- rep(c(0, 1), times = G * n)
  
  # Randomly assigning half of clusters to treatment
  treated_clusters <- sample(1:G, size = round(G / 2))
  treated <- ifelse(cluster_id %in% treated_clusters, 1, 0)
  
  # DiD interaction
  did <- treated * post
  
  # Data generating process:
  # outcome = treatment effect + random noise
  y <- beta * did + rnorm(G * n * 2, mean = 0, sd = sigma)
  
  data <- data.frame(
    y = y,
    cluster = factor(cluster_id),
    person = factor(person_id),
    post = post,
    did = did
  )
  
  # DiD regression with person FE and post FE
  # Cluster-robust SE at the cluster level
  model <- feols(y ~ did | person + post, data = data, cluster = ~cluster)
  
  # p-value for DiD coefficient
  pval <- pvalue(model)["did"]
  
  # Recording whether we reject or fail to reject the null hypothesis of no effect
  reject[r] <- (pval < alpha)
}

##### Power! ###################################################################
### What's our power given the DGP and our input parameters?
power_estimate <- mean(reject)
power_estimate

##### Varying Parameters #######################################################
### Now suppose we want to vary some of our inputs because we want to understand
### how as n increases, this affects power (among other parameters)
# This here is a function that wraps the for loop to allow for easier ability
# to vary the parameters down the road
did_power_mc <- function(G, n, beta, sigma, R = 1000, alpha = 0.05) {
  
  # Creating vectors for pvalues and the reject/fail to reject
  # Sometimes, creating the column and filling it with NAs can break less easily
  # than creating the column when the computer is inputting the data
  reject <- rep(FALSE, R)
  pvals  <- rep(NA_real_, R)

  # The same for loop as before
  for (r in 1:R) {
    
    cluster_id <- rep(1:G, each = n * 2)
    person_id  <- rep(1:(G * n), each = 2)
    post       <- rep(c(0, 1), times = G * n)
    
    treated_clusters <- sample(1:G, size = round(G / 2))
    treated <- ifelse(cluster_id %in% treated_clusters, 1, 0)
    
    did <- treated * post
    y <- beta * did + rnorm(G * n * 2, 0, sigma)
    
    data <- data.frame(
      y = y,
      cluster = factor(cluster_id),
      person  = factor(person_id),
      post    = factor(post),
      did     = did
    )
    
    model <- feols(y ~ did | person + post, data = data, cluster = ~cluster)
    
    pvals[r] <- pvalue(model)["did"]
    reject[r] <- (pvals[r] < alpha)
  }
  
  # power estimate
  power <- mean(reject)
  
  list(
    power = power,
    pvals = pvals,
    reject = reject,
    settings = list(G = G, n = n, beta = beta, sigma = sigma, R = R, alpha = alpha)
  )
}

### Wrapping the helper function with the actual function
# Here, I've wrapped the helper function (which wraps the for loop) with the 
# actual function we're using that allows us to vary parameters one at a time
# to understand how the no. of clusters, no. individuals in clusters, the effect
# size, etc. affect power

# This is the base parameters we used above
base <- list(G = 30, n = 50, beta = 0.20, sigma = 1.0, R = 1000, alpha = 0.05)

# Function as described right above
vary_params <- function(param, values, base) {
  
  power_vec <- rep(NA_real_, length(values))
  mcse_vec  <- rep(NA_real_, length(values))
  
  # Storing each full simulation object, one per value
  sims <- vector("list", length(values))
  
  # For loop along the defined parameter values
  for (i in seq_along(values)) {
    
    settings <- base
    settings[[param]] <- values[i]
    
    sims[[i]] <- did_power_mc(
      G = settings$G,
      n = settings$n,
      beta = settings$beta,
      sigma = settings$sigma,
      R = settings$R,
      alpha = settings$alpha
    )
    
    power_vec[i] <- sims[[i]]$power
  }
  
  df <- data.frame(
    parameter = param,
    value = values,
    power = power_vec,
    mc_se = mcse_vec
  )
  
  list(df = df, sims = sims, base = base)
}

# Setting the sequences
beta_vals <- seq(0, 0.5, by = 0.05)
sigma_vals <- seq(0.5, 2.0, by = 0.25)
G_vals <- c(10, 15, 20, 30, 40, 60, 80, 100)
n_vals <- c(10, 20, 30, 50, 75, 100, 150, 200)

# Run and SAVE each sweep as its own object
vary_beta <- vary_params("beta",  beta_vals,  base)
vary_sigma <- vary_params("sigma", sigma_vals, base)
vary_G <- vary_params("G", G_vals, base)
vary_n <- vary_params("n", n_vals, base)

##### Visualization ############################################################
### Let's see what the Monte Carlo simulation shows us about power here
plot_vary <- function(vary_obj, xlab) {
  ggplot(vary_obj$df, aes(x = value, y = power)) +
    geom_line() +
    geom_point() +
    ylim(0, 1) +
    labs(x = xlab, y = "Estimated Power") +
    theme_minimal(base_size = 13)
}

plot_vary(vary_beta,  "Effect size (beta)")
plot_vary(vary_sigma, "Noise (sigma)")
plot_vary(vary_G,     "Number of clusters (G)")
plot_vary(vary_n,     "Units per cluster (n)")

# Printing everything in one nice frame
all_vary <- rbind(
  vary_beta$df,
  vary_sigma$df,
  vary_G$df,
  vary_n$df
)

all_vary$parameter <- factor(
  all_vary$parameter,
  levels = c("beta", "sigma", "G", "n"),
  labels = c("Effect size (beta)", "Noise (sigma)", "Clusters (G)", "Units per cluster (n)")
)

ggplot(all_vary, aes(x = value, y = power)) +
  geom_line() +
  geom_point() +
  ylim(0, 1) +
  facet_wrap(~parameter, scales = "free_x") +
  labs(x = NULL, y = "Estimated Power") +
  theme_minimal(base_size = 13)
