# Load necessary library
pacman::p_load(tidyverse, gganimate)

# Function to calculate power
get_power <-
  function(effect_size, n_1, n_0, sd_1, sd_0, alpha = 0.05) {
    se <- sqrt(sd_1^2 / n_1 + sd_0^2 / n_0) # Standard error
    critical_value <- qnorm(1 - alpha / 2) # Critical value for two-tailed test
    noncentral_parameter <- effect_size / se # Non-central parameter
    power <-
      pnorm(-critical_value - noncentral_parameter) +
        (1 - pnorm(critical_value - noncentral_parameter))
    return(power)
  }

get_pvals <-
  function(n, p_1 = 0.5, sd_1 = 1, sd_0 = 1) {
    # Define parameters
    n_1 <- n * p_1 # Number of treated units
    n_0 <- n * (1 - p_1) # Number of control units
    # Define effect sizes to be tested
    effect_sizes <- seq(-sd_0, sd_0, by = 0.01)
    # Calculate power for each effect size
    power_values <-
      sapply(X = effect_sizes, FUN = function(effect_size) {
        get_power(effect_size, n_1, n_0, sd_1, sd_0)
      })
    # Create a data frame for plotting
    return(
      tibble(
        effect_size = effect_sizes,
        power = power_values
      )
    )
  }

powers <-
  lapply(
    seq(10, 600, by = 10),
    function(x) tibble(n = x, get_pvals(n = x))
  ) |>
    bind_rows() |>
    dplyr::mutate(
      power_treshold = if_else(power > 0.8, "above 0.8", "below 0.8")
    )

p <-
  # Plot power curve using ggplot2
  ggplot(powers, aes(x = effect_size, y = power, color = power_treshold)) +
    geom_hline(yintercept = 0.8, linetype = "dashed", color = "red") +
    geom_vline(
      xintercept = c(-0.25, 0.25),
      linetype = "dashed",
      color = "black"
    ) +
    geom_text(
      aes(x = 0.25, y = max(power), label = "0.25 of Control SD"),
      vjust = 1.5,
      hjust = 2.5,
      angle = 90,
      color = "black",
      size = 4
    ) +
    geom_text(
      aes(x = -0.25, y = max(power), label = "-0.25 of Control SD"),
      vjust = -0.5,
      hjust = 2.5,
      angle = 90,
      color = "black",
      size = 4
    ) +
    geom_point() +
    scale_y_continuous(breaks = seq(0, 1, 0.1), limits = c(0, 1)) +
    labs(
      title = "Power when sample size is N={closest_state}",
      x = "Effect Size",
      y = "Power",
      color = "Power is"
    ) +
    theme_bw(base_size = 15) +
    theme(legend.position = "bottom") +
    transition_states(n)

# Save animation
gganimate::animate(
  p,
  renderer = gifski_renderer(file = "_images/power.gif"),
  nframes = 60,
  duration = 15
)
