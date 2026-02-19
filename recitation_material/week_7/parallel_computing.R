################################################################################
################# This R Script Does the Following: ############################
### Provides a demonstration of the application of performing parallel
### processing in R using both forking and socket approaches. Code is repurposed
### from the previous recitation class on simulations in R. 
################################################################################
### Load packages, checking cores, and setting seed
if (!require(tidyverse)) install.packages("tidyverse")
if (!require(fixest)) install.packages("fixest")
if (!require(parallel)) install.packages("parallel")

# Checking number of cores available. You always want to keep at least one core
# free for other processes on your computer to use. Using all cores can also 
# increase likelihood of crashing your computer
cores <- detectCores() - 1

# Seed
seed_set <- set.seed(02192026)
set.seed(02192026)
##### Serial ###################################################################
### Existing power simulation
# Recall the simulation we performed last week in order to estimate power for 
# our clustered DiD under different counterfactuals
did_power_mc <- function(G, n, beta, sigma, R = 1000, alpha = 0.05) {
  # Initiating vectors
  reject <- rep(FALSE, R)
  pvals  <- rep(NA_real_, R)
  # For loop to simulate R times
  for (r in 1:R) {
    # Individual's cluster and unique id, also post var for DiD
    cluster_id <- rep(1:G, each = n * 2)
    person_id <- rep(1:(G * n), each = 2)
    post <- rep(c(0, 1), times = G * n)
    
    # Whether individual is in a treated cluster
    treated_clusters <- sample(1:G, size = round(G / 2))
    treated <- ifelse(cluster_id %in% treated_clusters, 1, 0)
    
    # "Model of the world" with treatment and regression equation
    did <- treated * post
    y <- beta * did + rnorm(G * n * 2, 0, sigma)
    
    # Making a df with relevant outcomes
    data <- data.frame(
      y = y,
      cluster = factor(cluster_id),
      person  = factor(person_id),
      post    = factor(post),
      did     = did
    )
    # Running the model with fixest and feols
    model <- fixest::feols(y ~ did | person + post, data = data, cluster = ~cluster)
    
    # Extracting pvals and whether we reject or not
    pvals[r] <- fixest::pvalue(model)["did"]
    reject[r] <- (pvals[r] < alpha)
  }
  # Our power
  power <- mean(reject)
  # Defining what the function outputs for thoroughness
  list(
    power = power,
    pvals = pvals,
    reject = reject,
    settings = list(G = G, n = n, beta = beta, sigma = sigma, R = R, alpha = alpha)
  )
}

# Here, I've wrapped the helper function (which wraps the for loop) with the 
# actual function we're using that allows us to vary parameters one at a time
# to understand how the no. of clusters, no. individuals in clusters, the effect
# size, etc. affect power
vary_params <- function(param, values, base) {
  
  power_vec <- rep(NA_real_, length(values))
  mcse_vec  <- rep(NA_real_, length(values))
  
  # What does this do?
  sims <- vector("list", length(values))
  
  # What does this do?
  for (i in seq_along(values)) {
    
    settings <- base
    settings[[param]] <- values[i]
    # What does this do?
    sims[[i]] <- did_power_mc(
      G = settings$G,
      n = settings$n,
      beta = settings$beta,
      sigma = settings$sigma,
      R = settings$R,
      alpha = settings$alpha
    )
    # What does this do?
    power_vec[i] <- sims[[i]]$power
  }
  # What does this do?
  df <- data.frame(
    parameter = param,
    value = values,
    power = power_vec,
    mc_se = mcse_vec
  )
  # What does this do?
  list(df = df, sims = sims, base = base)
}

### Demonstration
# Setting up base parameters that are "exogenous" (non-shifting)
base <- list(G = 30, n = 50, beta = 0.20, sigma = 1.0, R = 1000, alpha = 0.05)

# Running with "endogenous" parameter shifting:
serial_time <- system.time({
  vary_beta <- vary_params("beta",  seq(0, 0.5, by = 0.05),  base)
  })

# How much time did we spend?
serial_time

# Plot
plot_vary <- function(vary_obj, xlab) {
  ggplot(vary_obj$df, aes(x = value, y = power)) +
    geom_line() +
    geom_point() +
    ylim(0, 1) +
    labs(x = xlab, y = "Estimated Power") +
    theme_minimal(base_size = 13)
}

plot_vary(vary_beta,  "Effect size (beta)")

##### Forking #################################################################
### Let's run the function with parallel computing now
# Recall that child workers inherit settings from parent environemnt!
vary_params_fork <- function(
    param, values, base, cores = cores, seed = seed) {
  
  # Task list: one settings list per value of the parameter, each discrete value
  # "v" is processed by a node
  tasks <- lapply(values, function(v) {
    settings <- base
    settings[[param]] <- v
    settings
  })

  set.seed(seed)
  # The actual process of running in parallel
  sims <- parallel::mclapply(
    X = tasks,
    FUN = function(settings) {
      did_power_mc(
        G = settings$G,
        n = settings$n,
        beta = settings$beta,
        sigma = settings$sigma,
        R = settings$R,
        alpha = settings$alpha
      )
    },
    # Uses either the set no. cores or length of task vector, whichever is shorter
    mc.cores = min(cores, length(tasks)),
    # Parallel RNG setup for multicore: mc.set.seed=TRUE uses a parallel-safe
    # stream derived from current seed
    mc.set.seed = TRUE
  )
  # Extracts power calculations from each distinct object
  # vapply is a safer version of sapply, purrr:map_dbl also works
  power_vec <- vapply(sims, function(z) z$power, numeric(1))
  
  # Storing relevant outputs as a df
  df <- data.frame(
    parameter = param,
    value = values,
    power = power_vec
  )
  # Outputted objects from the function
  list(df = df, sims = sims, base = base)
}

# Running the function!
fork_time <- system.time({
  vary_beta_fork  <- vary_params_fork(
    "beta",  seq(0, 0.5, by = 0.05),  base, cores = cores, seed = seed_set
    )
    }
  )

# How much time did we spend? 7 times less time!
fork_time

# Let's compare the plot! They're the same!!!
plot_vary(vary_beta_fork,  "Effect size (beta)")

##### Socket ###################################################################
### Now let's try running the function with socket processes
# Recall that with socket, each child worker node doesn't inherit the parent
# R global environment. Thus, we need to specify loading packages and objects
# into each environment
vary_params_sock <- function(param, values, base, cores = cores, seed = seed) {
  
  # Setting up the process of creating new core clusters
  cores <- min(cores, length(values))
  cl <- parallel::makeCluster(cores)
  # With socket, we need to manually stop the cluster when it is finished
  on.exit(parallel::stopCluster(cl), add = TRUE)
  
  # Loading needed packages on each worker
  parallel::clusterEvalQ(cl, {
    require(fixest)
    NULL
  })
  
  # Exporting functions + objects referenced on workers
  # did_power_mc must exist on workers, plus base/param/values if referenced
  parallel::clusterExport(
    cl,
    varlist = c("did_power_mc"),
    envir = environment()
  )
  
  # Reproducible random streams across workers
  parallel::clusterSetRNGStream(cl, iseed = seed)
  
  # Building tasks (one settings list per value, same with forking)
  tasks <- lapply(values, function(v) {
    settings <- base
    settings[[param]] <- v
    settings
  })
  
  # Running with load balancing (mostly useful if task size/speed varies)
  sims <- parallel::parLapplyLB(
    cl,
    X = tasks,
    fun = function(settings) {
      did_power_mc(
        G = settings$G,
        n = settings$n,
        beta = settings$beta,
        sigma = settings$sigma,
        R = settings$R,
        alpha = settings$alpha
      )
    }
  )
  # Extracting power calculations from each sim
  power_vec <- vapply(sims, function(z) z$power, numeric(1))
  # Storing relevant parameters and power in a df
  df <- data.frame(
    parameter = param,
    value = values,
    power = power_vec
  )
  # List of outputted objecgts
  list(df = df, sims = sims, base = base)
}

# Running the function!
socket_time <- system.time({
  vary_beta_sock  <- vary_params_sock(
    "beta",  seq(0, 0.5, by = 0.05),  base, cores = cores, seed = seed_set
  )
}
)

# How much time did we spend?
socket_time

# Let's compare the plot!
plot_vary(vary_beta_sock,  "Effect size (beta)")

################################################################################