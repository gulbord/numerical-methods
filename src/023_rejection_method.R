library(ggplot2)
setwd("~/PoD/Y2.1/NMSM/exercises")

# system("exe/023a_rejection_sampling 100000")
read.csv("out/023a.csv", col.names = "x") |>
  ggplot() +
    geom_histogram(
      aes(x, after_stat(density)),
      alpha = 0.5,
      boundary = 0,
      binwidth = \(x) 2 * IQR(x) / length(x)^(1 / 3),
    ) +
    geom_function(fun = \(x) 2 * exp(-x^2) / sqrt(pi)) +
    labs(x = "<i>x</i>", y = "Density") +
    theme(axis.title.x = ggtext::element_markdown())

# system("exe/023b_rejection_accratio 5 5000 100000")
read.csv("out/023b.csv") |>
  ggplot() +
    geom_line(aes(p, acc)) +
    labs(x = "<i>p</i>", y = "Acceptance ratio") +
    theme(axis.title.x = ggtext::element_markdown())
