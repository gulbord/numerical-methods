library(data.table)
library(ggplot2)
setwd("~/PoD/Y2.1/NMSM/exercises/")

fread("out/022_mu1_sigma2.csv") |>
  melt(measure.vars = 1:2) |>
  ggplot() +
    geom_histogram(
      aes(value, after_stat(density)),
      boundary = 0,
      binwidth = \(x) 2 * IQR(x) / length(x)^(1 / 3),
    ) +
    geom_function(fun = dnorm, args = list(mean = 1, sd = 2)) +
    facet_wrap(
      vars(variable),
      nrow = 2,
      labeller = as_labeller(
        c(x = "<i>r</i> cos(<i>θ</i>)", y = "<i>r</i> sin(<i>θ</i>)")
      )
    ) +
    labs(x = "Sampled value", y = "Density") +
    theme(strip.text = ggtext::element_markdown())
