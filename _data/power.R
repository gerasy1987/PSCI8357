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
    effect_sizes <- round(seq(-sd_0, sd_0, by = 0.01), 2)
    power_values <-
      sapply(effect_sizes, function(es) get_power(es, n_1, n_0, sd_1, sd_0))
    tibble(
      effect_size = effect_sizes,
      power = power_values
    )
  }

n_values <- seq(10, 600, by = 10)

powers <-
  lapply(
    n_values,
    function(x) tibble(n = x, get_pvals(n = x))
  ) |>
    bind_rows() |>
    mutate(
      powered = if_else(power >= 0.8, "Above 0.8", "Below 0.8")
    ) |>
    arrange(n, effect_size)

mde_80 <-
  powers |>
    filter(effect_size >= 0) |>
    group_by(n) |>
    summarize(
      mde_80 = ifelse(any(power >= 0.8), min(effect_size[power >= 0.8]), NA_real_),
      .groups = "drop"
    ) |>
    mutate(
      mde_label = if_else(
        is.na(mde_80),
        "MDE-80 > 1.00 SD",
        paste0("MDE-80 = ", format(mde_80, nsmall = 2), " SD")
      ),
      mde_label_x = pmin(0.92, coalesce(mde_80, 1) + 0.06)
    )

frame_notes <-
  powers |>
    filter(abs(effect_size - 0.25) < 1e-9) |>
    transmute(
      n,
      note_head = paste0(
        "At N = ",
        n,
        ", 0.25 SD has ",
        round(power * 100),
        "% power."
      )
    ) |>
    left_join(mde_80 |> select(n, mde_label), by = "n") |>
    mutate(note = paste(note_head, mde_label, sep = "\n"))

power_zones <-
  tibble(
    ymin = c(0, 0.8),
    ymax = c(0.8, 1),
    zone_fill = c("#fbe9dd", "#deeddc")
  )

p <-
  ggplot(powers, aes(x = effect_size, y = power, group = effect_size)) +
    geom_rect(
      data = power_zones,
      aes(
        xmin = -Inf,
        xmax = Inf,
        ymin = ymin,
        ymax = ymax,
        fill = zone_fill
      ),
      inherit.aes = FALSE,
      alpha = 0.35,
      show.legend = FALSE
    ) +
    geom_hline(
      yintercept = 0.8,
      linetype = "dashed",
      linewidth = 0.7,
      color = "#928374"
    ) +
    geom_vline(
      xintercept = c(-0.25, 0.25),
      linetype = "dashed",
      linewidth = 0.5,
      color = "#928374"
    ) +
    geom_point(
      aes(color = powered),
      alpha = 0.85,
      size = 0.9
    ) +
    geom_segment(
      data = mde_80 |> filter(!is.na(mde_80)),
      aes(x = mde_80, xend = mde_80, y = 0, yend = 0.8),
      inherit.aes = FALSE,
      color = "#458588",
      linewidth = 0.8,
      linetype = "dotdash"
    ) +
    geom_point(
      data = mde_80 |> filter(!is.na(mde_80)),
      aes(x = mde_80, y = 0.8),
      inherit.aes = FALSE,
      color = "#458588",
      size = 2
    ) +
    geom_label(
      data = mde_80,
      aes(x = mde_label_x, y = 0.11, label = mde_label),
      inherit.aes = FALSE,
      size = 3,
      fill = "#ebf1e8",
      color = "#3c3836",
      linewidth = 0.15,
      label.padding = grid::unit(0.12, "lines"),
      label.r = grid::unit(0.15, "lines")
    ) +
    geom_label(
      data = frame_notes,
      aes(x = -0.98, y = 0.03, label = note),
      inherit.aes = FALSE,
      hjust = 0,
      vjust = 0,
      size = 3.1,
      lineheight = 1.05,
      fill = "#fdf6e3",
      color = "#3c3836",
      linewidth = 0
    ) +
    scale_fill_identity() +
    scale_color_manual(
      values = c(
        "Below 0.8" = "#cc241d",
        "Above 0.8" = "#689d6a"
      ),
      breaks = c("Below 0.8", "Above 0.8")
    ) +
    scale_x_continuous(
      breaks = seq(-1, 1, by = 0.25),
      limits = c(-1, 1)
    ) +
    scale_y_continuous(
      breaks = seq(0, 1, 0.2),
      limits = c(0, 1)
    ) +
    labs(
      title = "Power Curve (N = {closest_state})",
      subtitle = "Red points are underpowered; green points meet the 80% target",
      x = bquote("Effect Size (" ~ tau / sigma[0] ~ ")"),
      y = "Power",
      color = NULL,
      caption = "Shaded bands show below-target (<80%) versus target (>=80%) power."
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
      plot.subtitle = element_text(color = "#504945"),
      plot.caption = element_text(color = "#665c54", hjust = 0),
      legend.background = element_rect(fill = "#f0f1eb", color = NA),
      legend.key = element_rect(fill = "#f0f1eb", color = NA),
      legend.text = element_text(color = "#3c3836"),
      legend.position = "bottom"
    ) +
    transition_states(
      n,
      transition_length = 2,
      state_length = 1,
      wrap = FALSE
    ) +
    ease_aes("cubic-in-out")

# Save animation
gganimate::animate(
  p,
  renderer = gifski_renderer(file = "_images/power.gif"),
  nframes = 180,
  fps = 12,
  end_pause = 20,
  bg = "#f0f1eb"
)
