pacman::p_load(tidyverse)

df_lee <- readr::read_csv("_data/lee.csv")

df_lee <- 
df_lee |> 
dplyr::filter(party == "100") |> 
dplyr::mutate(
  share_t = origvote / totvote,
  margin_t = origvote / (highestvote + sechighestvote) - 0.5
) |> 
dplyr::group_by(
  state, distnum, distid, party
) |> 
dplyr::mutate(
  margin_tm1 = dplyr::lag(margin_t, n = 1),
  margin_tm2 = if (n() < 3) NA else dplyr::lag(margin_t, n = 2)
) |> 
dplyr::ungroup() |> 
dplyr::mutate(incumbent = if_else(margin_tm1 > 0, 1, 0))

df_lee <- readr::write_csv(df_lee, "_data/lee_mod.csv")
