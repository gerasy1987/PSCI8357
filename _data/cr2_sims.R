pacman::p_load(
  tidyverse,
  gganimate,
  estimatr
)

set.seed(20250210)

# Simulation parameters
n_clusters <- 50
n_per_cluster <- 10
n_simulations <- 100

# Function to generate clustered data and estimate treatment effect
simulate <- function(rel, sims = 100) {
  replicate(
    n = 1000,
    {
      tau <- 2
      base_sd <- 2
      dat <-
        tibble(
          cluster_id = rep(1:n_clusters, each = n_per_cluster),
          treatment = rep(
            randomizr::complete_ra(N = n_clusters, prob = 0.5),
            each = n_per_cluster
          ), # Cluster-level treatment assignment
          between_cluster = rep(
            rnorm(n_clusters, mean = 0, sd = base_sd * rel),
            each = n_per_cluster
          ), # Cluster-level shocks
          within_cluster = rnorm(
            n_clusters * n_per_cluster,
            mean = 0,
            sd = base_sd
          ),
          outcome = tau * treatment + between_cluster + within_cluster
        )
      # Naive regression (ignoring clustering)
      naive_model <- estimatr::lm_robust(outcome ~ treatment, dat)

      # Corrected regression (accounting for clustering)
      robust_se <- estimatr::lm_robust(
        outcome ~ treatment,
        clusters = cluster_id,
        dat
      )

      c(
        rel = rel,
        HC2 = unname(
          tau >= naive_model$conf.low[2] & tau <= naive_model$conf.high[2]
        ),
        CR2 = unname(
          tau >= robust_se$conf.low[2] & tau <= robust_se$conf.high[2]
        )
      )
    }
  ) |>
    apply(MARGIN = 1, mean)
}

# Run simulations
results <-
  bind_rows(pbapply::pblapply(seq(0.05, 2, by = .05), simulate, cl = 8))

write_rds(results, "_data/cr2_sims.rds")

results <- read_rds("_data/cr2_sims.rds")

# Prepare data for animation
results_long <-
  results |>
    pivot_longer(cols = c("HC2", "CR2"), names_to = "method", values_to = "se")

# Plot animation
p <-
  ggplot(results_long, aes(x = se, y = rel, color = method, shape = method)) +
    geom_hline(
      aes(yintercept = rel),
      linetype = "dashed",
      alpha = .5,
      size = .25
    ) +
    geom_point(size = 4, alpha = 1) +
    labs(
      title = ,
      x = "Coverage",
      color = "Std. Errors",
      shape = "Std. Errors",
      y = bquote("Ratio of Between to Within SD (" ~ sigma[B] / sigma[W] ~ ")")
    ) +
    scale_x_continuous(breaks = seq(0.45, 1, by = 0.05)) +
    scale_color_manual(values = c("#98971a", "#cc241d")) +
    theme_bw() +
    transition_components(rel)

# Save animation
gganimate::animate(
  p,
  renderer = gifski_renderer(file = "_images/cr2_coverage.gif"),
  fps = 15,
  duration = 15
)
