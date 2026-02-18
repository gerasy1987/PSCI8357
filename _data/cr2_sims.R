pacman::p_load(
  tidyverse,
  gganimate,
  estimatr
)

set.seed(20250210)

# Simulation parameters
n_clusters <- 50
n_per_cluster <- 10
n_sims <- 1000

# Function to generate clustered data and estimate treatment effect
simulate <- function(rel) {
  replicate(
    n = n_sims,
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

# Convert SD ratio to ICC: rho = rel^2 / (rel^2 + 1)
results <- results |>
  mutate(icc = rel^2 / (rel^2 + 1))

write_rds(results, "_data/cr2_sims.rds")

results <- read_rds("_data/cr2_sims.rds")

# Prepare data for animation
results_long <-
  results |>
    pivot_longer(cols = c("HC2", "CR2"), names_to = "method", values_to = "coverage")

# Plot animation
p <-
  ggplot(results_long, aes(x = coverage, y = icc, color = method, shape = method)) +
    annotate(
      "rect",
      xmin = -Inf,
      xmax = 0.95,
      ymin = -Inf,
      ymax = Inf,
      fill = "#fbe9dd",
      alpha = 0.35
    ) +
    geom_vline(
      xintercept = 0.95,
      linetype = "dashed",
      linewidth = 0.6,
      color = "#928374"
    ) +
    geom_hline(
      aes(yintercept = icc),
      linetype = "dashed",
      alpha = .5,
      linewidth = .25
    ) +
    geom_point(size = 4, alpha = 1) +
    labs(
      title = "95% CI Coverage (G = {n_clusters}, n = {n_per_cluster})",
      x = "Coverage",
      color = "Std. Errors",
      shape = "Std. Errors",
      y = bquote("ICC (" ~ rho ~ ")")
    ) +
    scale_x_continuous(breaks = seq(0.45, 1, by = 0.05)) +
    scale_y_continuous(breaks = seq(0, 1, by = 0.1)) +
    scale_color_manual(values = c("#98971a", "#cc241d")) +
    theme_minimal(base_size = 14) +
    theme(
      plot.background = element_rect(fill = "#f0f1eb", color = NA),
      panel.background = element_rect(fill = "#f0f1eb", color = NA),
      panel.grid.major = element_line(color = "#d5c4a1", linewidth = 0.3),
      panel.grid.minor = element_blank(),
      text = element_text(color = "#3c3836"),
      axis.text = element_text(color = "#504945"),
      axis.title = element_text(color = "#3c3836"),
      plot.title = element_text(color = "#3c3836"),
      legend.background = element_rect(fill = "#f0f1eb", color = NA),
      legend.key = element_rect(fill = "#f0f1eb", color = NA),
      legend.text = element_text(color = "#3c3836"),
      legend.title = element_text(color = "#3c3836")
    ) +
    transition_components(icc)

# Save animation
gganimate::animate(
  p,
  renderer = gifski_renderer(file = "_images/cr2_coverage.gif"),
  nframes = 40,
  duration = 15,
  bg = "#f0f1eb"
)
