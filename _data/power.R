# Load necessary library
pacman::p_load(tidyverse, gganimate)

# Function to calculate power
get_power <-
  function(effect_size, n_1, n_0, sd_1, sd_0, alpha = 0.05) {
    se <- sqrt(sd_1^2 / n_1 + sd_0^2 / n_0)
    z_alpha <- qnorm(1 - alpha / 2)
    ncp <- effect_size / se
    power <- pnorm(-z_alpha - ncp) + (1 - pnorm(z_alpha - ncp))
    return(power)
  }

get_pvals <-
  function(n, p_1 = 0.5, sd_1 = 1, sd_0 = 1) {
    n_1 <- n * p_1
    n_0 <- n * (1 - p_1)
    effect_sizes <- seq(-sd_0, sd_0, by = 0.01)
    power_values <-
      sapply(effect_sizes, function(es) get_power(es, n_1, n_0, sd_1, sd_0))
    tibble(
      effect_size = effect_sizes,
      power = power_values
    )
  }

powers <-
  lapply(
    seq(10, 600, by = 10),
    function(x) tibble(n = x, get_pvals(n = x))
  ) |>
    bind_rows() |>
    mutate(
      powered = if_else(power > 0.8, "above 0.8", "below 0.8")
    )

p <-
  ggplot(powers, aes(x = effect_size, y = power, color = powered)) +
    geom_hline(
      yintercept = 0.8,
      linetype = "dashed",
      linewidth = 0.6,
      color = "#928374"
    ) +
    geom_vline(
      xintercept = c(-0.25, 0.25),
      linetype = "dashed",
      linewidth = 0.5,
      color = "#928374"
    ) +
    annotate(
      "text",
      x = 0.27, y = 0.98,
      label = "0.25 SD",
      hjust = 0, size = 3.5,
      color = "#504945"
    ) +
    annotate(
      "text",
      x = -0.27, y = 0.98,
      label = "-0.25 SD",
      hjust = 1, size = 3.5,
      color = "#504945"
    ) +
    geom_point(alpha = .75, size = .75) +
    scale_y_continuous(breaks = seq(0, 1, 0.2), limits = c(0, 1)) +
    scale_color_manual(values = c("#98971a", "#cc241d")) +
    labs(
      title = "Power Curve (N = {closest_state})",
      x = bquote("Effect Size (" ~ tau / sigma[0] ~ ")"),
      y = "Power",
      color = NULL
    ) +
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
      legend.position = "bottom"
    ) +
    transition_states(n)

# Save animation
gganimate::animate(
  p,
  renderer = gifski_renderer(file = "_images/power.gif"),
  nframes = 60,
  duration = 15,
  bg = "#f0f1eb"
)
