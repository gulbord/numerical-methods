setwd("~/PoD/Y2.1/NMSM/exercises")
source("src/preamble.R")

k1 <- 3
k2 <- 0.01
k3 <- 5

run_sim <- function(init_prey, init_pred, max_time) {
  exe <- sprintf(
    "exe/071_lotka_volterra %s %g %g %g %d %d %g",
    sprintf("%d_%d", init_prey, init_pred),
    k1, k2, k3,
    init_prey, init_pred, max_time
  )
  system(exe)
}

plot_ex <- function(init_prey, init_pred, max_time) {
  run_sim(init_prey, init_pred, max_time)
  fread(sprintf("out/071_%d_%d.csv", init_prey, init_pred)) |>
    setnames(-1, \(n) paste("curr", n, sep = ".")) |>
    _[order(time)] |>
    _[, let(eq.prey = k3 / k2, eq.pred = k1 / k2)] |>
    melt(
      id.vars = "time",
      measure.vars = measure(value.name, species, sep = ".")
    ) |>
    _[, species := factor(
      species,
      levels = if (k3 > k1) c("prey", "pred") else c("pred", "prey"),
      labels = if (k3 > k1) c("Prey", "Predators") else c("Predators", "Prey")
    )] |>
    ggplot(aes(colour = species)) +
      geom_line(aes(time, curr)) +
      geom_line(aes(time, eq), linetype = "dashed") +
      scale_x_continuous(
        breaks = scales::pretty_breaks(),
        limits = c(0, max_time),
      ) +
      scale_y_continuous(breaks = scales::pretty_breaks()) +
      labs(x = "Time (s)", y = "Population", colour = "Species")
}

plot_ex(500, 250, 15)

fread("out/071_500_250.csv") |>
  _[, .(dt = diff(time))] |>
  ggplot() +
    geom_histogram(
      aes(dt, after_stat(density)),
      binwidth = \(x) 2 * IQR(x) / length(x)^(1 / 3)
    )
