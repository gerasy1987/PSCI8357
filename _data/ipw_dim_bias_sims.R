# Simulate data
set.seed(20250212)

pacman::p_load(
  tidyverse,
  pbapply,
  ggdist,
  gganimate
)

# Function to calculate bias for different spreads
calculate_bias <-
  function(spr, tau = .5, N = 1000, base = 0.45, alpha = 0) {
    p <- runif(n = N, min = base - spr, max = base + spr)
    T_i <- rbinom(n = N, size = 1, prob = p)
    Y_0 <- rnorm(N)
    Y_1 <- Y_0 + 3 * (p + alpha * (base - p))
    Y_i <- ifelse(T_i == 1, Y_1, Y_0)
    DiM <- mean(Y_i[T_i == 1]) - mean(Y_i[T_i == 0])
    IPW <- mean(T_i * Y_i / p) - mean((1 - T_i) * Y_i / (1 - p))
    tibble(
      alp = alpha,
      spr = spr,
      DiM = DiM - mean(3 * (p + alpha * (base - p))),
      IPW = IPW - mean(3 * (p + alpha * (base - p)))
    )
  }

# Calculate bias for different sprs
params <-
  expand_grid(
    alphas = seq(1, 0, by = -0.1),
    sprs = seq(0, 0.4, by = 0.05)
  )

bias_data <-
  pbmapply(
    function(x, y) {
      bind_rows(
        replicate(n = 150, calculate_bias(spr = x, alpha = y), simplify = FALSE)
      )
    },
    x = params$sprs,
    y = params$alphas,
    SIMPLIFY = FALSE
  ) |>
    bind_rows() |>
    pivot_longer(
      cols = c(DiM, IPW),
      names_to = "estimator",
      values_to = "bias"
    ) |>
    dplyr::mutate(spr = 2 * spr, alp = (1 - alp))

write_rds(bias_data, "_data/ipw_dim_bias_sims.rds")
bias_data <- read_rds("_data/ipw_dim_bias_sims.rds")

p <-
  # Plot using ggplot2
  ggplot(
    bias_data,
    aes(
      x = spr,
      y = bias,
      fill = estimator,
      color = estimator,
      shape = estimator
    )
  ) +
    geom_hline(
      yintercept = 0,
      linetype = "dashed",
      linewidth = 1,
      color = "#928374"
    ) +
    # geom_smooth(se = FALSE, method = "loess") +
    ggdist::stat_halfeye(
      adjust = .25, ## bandwidth
      # width = .01,
      # color = NA, ## remove slab interval
      # fill = "#b16286", ## remove slab interval
      # point_interval = "mean_hdci",
      position = position_dodge(width = 0.02),
      # interval_size_range = c(1,1),
      slab_alpha = 0.3,
      interval_alpha = 0,
      point_alpha = 0,
    ) +
    stat_summary(
      fun.data = mean_cl_boot,
      geom = "pointrange",
      linewidth = 1,
      size = 0.75,
      position = position_dodge(width = 0.02)
    ) +
    # geom_jitter(alpha = .25, size = 1, height = 0, width = 0.002) +
    scale_color_manual(values = c("#689d6a", "#cc241d")) +
    scale_fill_manual(values = c("#689d6a", "#cc241d")) +
    scale_y_continuous(limits = c(-.3, .6)) +
    scale_x_continuous(breaks = seq(0, 0.8, by = 0.1)) +
    labs(
      title = "Individual treatment effects diverge by ~ {closest_state} x Spread",
      x = "Spread of Assignment Probabilities",
      y = "Bias",
      color = "Estimator",
      fill = "Estimator",
      shape = "Estimator"
    ) +
    transition_states(alp) +
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
    )

# Save animation
gganimate::animate(
  p,
  renderer = gifski_renderer(file = "_images/ipw_dim_bias.gif"),
  nframes = 100,
  duration = 15,
  bg = "#f0f1eb"
)
