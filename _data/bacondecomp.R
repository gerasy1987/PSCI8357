pacman::p_load(tidyverse, fixest, bacondecomp)

set.seed(04092025)

n <- 600

n_1 <- 100
n_2 <- 250
n_99999 <- n - n_1 - n_2

# Step 1: Create panel
df <-
  tidyr::expand_grid(
    year = 0:2,
    id = 1:n
  ) |>
  mutate(
    id_group = case_when(
      id <= n_1 ~ 1,
      id > n_1 & id <= n_1 + n_2 ~ 2,
      id > n_1 + n_2 ~ 99999
    ),
    treat_year = id_group,
    D = as.numeric(year >= treat_year),
    # true treatment effect is 2
    Y = 5 +
      1 * (id_group == 1) + 2 * (id_group == 2) + # unit FE
      0.5 * year +                                # year trend
      3 * D +                                     # base treatment effect
      1 * D * (id_group != 99999 & year > treat_year) + # dynamic treatment effect
      rnorm(n(), 0, 1), 
  )

panelView::panelview(
    data = df,
    Y ~ D,
    index = c("id", "year"),
    xlab = "Year",
    ylab = "Group",
    type = "treat",
    theme.bw = FALSE,
    display.all = TRUE,
    by.timing = TRUE
  )

panelView::panelview(
  data = df, Y ~ D,
    index = c("id", "year"),
    xlab = "Year",
    ylab = "Y", type = "outcome", theme.bw = FALSE,
  display.all = T, gridOff = TRUE, color = c("lightblue", "blue", "#99999950"), 
  axis.lab.angle = 90
  )

model <- feols(Y ~ D | id + year, data = df, cluster = "id")

model

group_comp <- combn(c(1,2,99999), 2, simplify = FALSE)
year_comp <- combn(0:2, 2, simplify = FALSE)

group_comp_names <- group_comp |> lapply(X = _, paste0, collapse = " vs ")
year_comp_names <- year_comp |> lapply(X = _, paste0, collapse = " vs ")

coefs <-
  matrix(
    data = NA_real_,
    nrow = 3,
    ncol = 3,
    dimnames = list(group = group_comp_names, year = year_comp_names)
  )

for (j in seq_along(year_comp)) {
  for (i in seq_along(group_comp)) {
    est <-
      try(
        {
          df |>
            dplyr::filter(
              (year %in% year_comp[[j]]) &
                (id_group %in% group_comp[[i]])
            ) |>
            feols(Y ~ D | id + year, data = _, cluster = "id")
        },
        silent = TRUE
      )

    if (class(est) == "try-error") {
      coefs[i, j] <- NA_real_
    } else {
      coefs[i, j] <- est$coefficients[["D"]]
    }
  }
}

coefs_correct <- coefs
coefs_correct[1,3] <- NA

weights <- c("1 vs 2" =  n_1*n_2, "1 vs 99999" = n_1*n_99999, "2 vs 99999" = n_2*n_99999)
weights <- weights / sum(weights)

weights_sample <- c("1 vs 2" =  n_1 + n_2, "1 vs 99999" = n_1 + n_99999, "2 vs 99999" = n_2 + n_99999)
weights_sample <- weights_sample / sum(weights_sample)

c(
  "est_twfe" = model$coefficients[["D"]],
  "est_bacondecomp" = sum(apply(coefs, 1, mean, na.rm = TRUE) * weights),
  "est_correct" = sum(apply(coefs_correct, 1, mean, na.rm = TRUE) * weights_sample)
)

coefs[2:3,] |> apply(MARGIN = 1, mean, na.rm = TRUE)

df_bacon <- bacon(
  Y ~ D,
  data = df,
  id_var = "id",
  time_var = "year",
  quietly = TRUE
)

df_bacon

ggplot(
  df_bacon,
  aes(x = weight, y = estimate, shape = factor(type), color = factor(type))
) +
  geom_hline(
    yintercept = model$coefficients[["D"]],
    color = "#cc241d",
    linetype = "dashed"
  ) +
  labs(x = "Weight", y = "Estimate", shape = "Type", color = 'Type') +
  geom_point() +
  theme_bw(base_size = 20)
