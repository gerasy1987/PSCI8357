## FOR WEIGHTING

sims <-
  pbapply::pbreplicate(
    1000,
    {
      X <- sample(0:3, prob = c(.5, .4, 0, .1), N, replace = TRUE)
      probs <- 0.5 + 0.15 * X
      D <- randomizr::simple_ra(N, prob_unit = probs)
      Y <- true_tau * D - 15 * X + rnorm(N, sd = 5)
      ps <- predict(glm(D ~ X))

      ht_ate_true <- get_ht_ate(Y, D, probs)

      ht_ate <- get_ht_ate(Y, D, ps)

      hajek_ate <- (sum(D * Y / ps) / sum(D / ps)) -
        (sum((1 - D) * Y / (1 - ps)) / sum((1 - D) / (1 - ps)))

      # hajek_ate <- estimatr::lm_robust(
      #   Y ~ D + X,
      #   weights = (D / ps_norm) + ((1 - D) / (1 - ps_norm))
      # )$coefficients[["D"]]

      tibble(
        Estimator = c("HT True", "HT", "Hajek"),
        Estimate = c(ht_ate_true, ht_ate, hajek_ate)
      )
    },
    simplify = FALSE
  ) |>
  bind_rows()

sims_sd <-
  sims |>
  group_by(Estimator) |>
  summarize(sd = sd(Estimate)) |>
  dplyr::mutate(sd = round(sd, digits = 2))


# Create density plots for HT and Hajek estimates
ggplot(sims, aes(x = Estimate, fill = Estimator, color = Estimator)) +
  geom_density(alpha = 0.5) +
  geom_vline(xintercept = 2, linetype = "dashed", size = 1) +
  scale_fill_manual(
    values = c("HT True" = "#b16286", "HT" = "#cc241d", "Hajek" = "#689d6a"),
    labels = apply(sims_sd, 1, paste0, collapse = "\nSD=")
  ) +
  scale_color_manual(
    values = c("HT True" = "#b16286", "HT" = "#cc241d", "Hajek" = "#689d6a"),
    labels = apply(sims_sd, 1, paste0, collapse = "\nSD=")
  ) +
  scale_x_continuous(limits = c(-15, 15)) +
  labs(
    x = "Estimates",
    y = "Density",
    fill = "Estimator"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")

# GET WEIGHTING BY HAND AND USE ESTIMATR

set.seed(20251024)

# Simulation parameters
N <- 1000
true_tau <- 2

X <- sample(0:3, N, replace = TRUE)
probs <- 0.5 + 0.1 * X
D <- randomizr::simple_ra(N, prob_unit = probs)
Y <- true_tau * D - X + rnorm(N, sd = 5)
ps <- glm(D ~ X, family = binomial)$fitted.values
# ht_ate <- mean(D * Y / ps - (1 - D) * Y / (1 - ps))
ht_ate <- estimatr::horvitz_thompson(
  Y ~ D,
  condition_prs = ps,
  se_type = "young"
)$std.error[["D"]]
# hajek_ate <- (sum(D * Y / ps) / sum(D / ps)) - (sum((1 - D) * Y / (1 - ps)) / sum((1 - D) / (1 - ps)))
hajek_ate <- estimatr::lm_robust(
  Y ~ D + X,
  weights = D / ps + (1 - D) / (1 - ps)
)$std.error[["D"]]

estimatr::lm_robust(
  Y ~ D + X,
  weights = D / ps + (1 - D) / (1 - ps)
)

w <- D / ps + (1 - D) / (1 - ps)
w <- w / sum(w)

# Replicate weighting by hand
Y_mod <- sqrt(w) * Y
D_mod <- sqrt(w) * D
X_mod <- sqrt(w) * X

estimatr::lm_robust(
  Y_mod ~ -1 + sqrt(w) + D_mod + X_mod
)


hajek_att <- (sum(D * Y) / sum(D)) - (sum((1 - D) * Y * ps / (1 - ps)) / sum(D))

hajek_att <- estimatr::lm_robust(
  Y ~ D + X,
  weights = D + (1 - D) * ps / (1 - ps)
)$std.error[["D"]]

ps1 <- WeightIt::weightit(D ~ X, method = "ps", estimand = "ATE")

ps1$weights


## AIPW

pacman::p_load(drtmle, SuperLearner, tidyverse, estimatr)

set.seed(20250226)

get_estimates <-
  function(
    tau = 0.8,
    n = 1000,
    wrong_model = c("regression", "weighting")
  ) {
    wrong_model <- match.arg(wrong_model)

    X <- rnorm(n) # confounder
    D <- rbinom(n, 1, plogis(0.5 * X)) # treatment assignment with propensity depending on X
    Y <- tau * D + X + rnorm(n) # outcome depends on treatment and confounder

    if (wrong_model == "regression") {
      outcome_model <- Y ~ D # incorrect
      treatment_model <- D ~ X # correct
    } else if (wrong_model == "weighting") {
      outcome_model <- Y ~ D + X # correct
      treatment_model <- D ~ 1 # incorrect
    }

    # naive regression
    reg_ate <- estimatr::lm_robust(outcome_model)$coefficients[["D"]]

    # ipw estimator
    prop_scores <- predict(
      glm(treatment_model, family = binomial),
      type = "response"
    )
    ipw_ate <- estimatr::lm_robust(
      Y ~ D,
      weights = (D / prop_scores) + ((1 - D) / (1 - prop_scores))
    )$coefficients[["D"]]

    # aipw (doubly robust) estimator by hand
    outcome_predict <-
      estimatr::lm_robust(outcome_model) |>
      (\(.)
        cbind(
          # predict Y(1) and Y(0) for each observation based
          # on the outcome model
          mu1 = predict(., newdata = data.frame(D = 1, X = X)),
          mu0 = predict(., newdata = data.frame(D = 0, X = X))
        ))()

    aipw_ate <- mean(
      (D * (Y - outcome_predict[, "mu1"]) / prop_scores) -
        ((1 - D) * (Y - outcome_predict[, "mu0"]) / (1 - prop_scores)) +
        (outcome_predict[, "mu1"] - outcome_predict[, "mu0"])
    )

    # aipw in practice using machine learning!
    aipw_ate_ml <-
      drtmle(
        W = data.frame(X = X), # covariates
        A = D, # treatment (exposure)
        Y = Y, # outcome
        SL_g = "SL.glm",
        SL_gr = "SL.glm", # model for treatment
        SL_Q = "SL.lm",
        SL_Qr = "SL.lm" # model for outcome
      )$drtmle$est |>
      diff() |>
      abs()

    # cat("AIPW ATE:", aipw_ate, "\n")

    # Results comparison
    return(
      tibble(
        Estimator = c(
          "Naive Regression",
          "IPW",
          "AIPW by hand",
          "AIPW (drtmle)"
        ),
        Estimate = c(reg_ate, ipw_ate, aipw_ate, aipw_ate_ml)
      )
    )
  }

sims_regression_wrong <-
  pbapply::pbreplicate(
    500,
    get_estimates(wrong_model = "regression"),
    simplify = FALSE,
    cl = 6
  ) |>
  bind_rows()

sims_weighting_wrong <-
  pbapply::pbreplicate(
    500,
    get_estimates(wrong_model = "weighting"),
    simplify = FALSE,
    cl = 6
  ) |>
  bind_rows()

p1 <-
  ggplot(
    sims_regression_wrong,
    aes(y = Estimator, x = Estimate, fill = Estimator)
  ) +
  ggdist::stat_slab(aes(thickness = after_stat(pdf * n)), scale = 0.25) +
  ggdist::stat_dotsinterval(side = "bottom", scale = 0.7, slab_linewidth = NA) +
  geom_vline(xintercept = 0.8, linetype = "dashed", linewidth = 1) +
  scale_fill_manual(
    values = c(
      "Naive Regression" = "#689d6a",
      "IPW" = "#cc241d",
      "AIPW by hand" = "#928374",
      "AIPW (drtmle)" = "#458588"
    ),
    breaks = c("Naive Regression", "IPW", "AIPW by hand", "AIPW (drtmle)")
  ) +
  labs(
    title = "Regression is wrong",
    x = "Estimates",
    y = "Density by Estimator",
    fill = "Estimator"
  ) +
  theme_minimal(base_size = 14) +
  theme(axis.text.y = element_blank())

p2 <-
  ggplot(
    sims_weighting_wrong,
    aes(y = Estimator, x = Estimate, fill = Estimator)
  ) +
  ggdist::stat_slab(aes(thickness = after_stat(pdf * n)), scale = 0.25) +
  ggdist::stat_dotsinterval(side = "bottom", scale = 0.7, slab_linewidth = NA) +
  geom_vline(xintercept = 0.8, linetype = "dashed", linewidth = 1) +
  scale_fill_manual(
    values = c(
      "Naive Regression" = "#689d6a",
      "IPW" = "#cc241d",
      "AIPW by hand" = "#928374",
      "AIPW (drtmle)" = "#458588"
    ),
    breaks = c("Naive Regression", "IPW", "AIPW by hand", "AIPW (drtmle)")
  ) +
  labs(
    title = "Weighting is wrong",
    x = "Estimates",
    y = NULL,
    fill = "Estimator"
  ) +
  theme_minimal(base_size = 14) +
  theme(axis.text.y = element_blank())


p1 +
  p2 +
  plot_layout(ncol = 2, guides = "collect") &
  theme(legend.position = "right")
