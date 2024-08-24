library(data.table)
library(ggplot2)
setwd("~/PoD/Y2.1/NMSM/exercises")

df <- fread("out/084_N100_r0.5_d0.3_T2_icubic_s50000.csv") |>
  _[, energy := energy / 100] |>
  _[, iter := 1:.N, by = realization]

df[, c(mean = lapply(.SD, mean), sd = lapply(.SD, sd)),
   , by = iter, .SDcols = c("energy", "pressure")] |>
  setnames(-1, c("energy.mean", "pressure.mean", "energy.sd", "pressure.sd")) |>
  melt(
    id.vars = "iter",
    measure.vars = measure(variable, value.name, sep = ".")
  ) |>
  ggplot() +
    geom_ribbon(
      aes(iter, ymin = mean - sd, ymax = mean + sd),
      alpha = 0.5,
    ) +
    geom_line(aes(iter, mean)) +
    geom_hline(aes(yintercept = df[iter > 2e4L, mean(pressure)])) +
    facet_wrap(
      vars(variable),
      nrow = 2,
      scales = "free_y",
      labeller = as_labeller(c(energy = "Energy", pressure = "Pressure")),
    ) +
    labs(x = "Monte Carlo sweeps", y = "Average over 10 realizations")
