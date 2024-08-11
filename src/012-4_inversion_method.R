library(data.table)
library(ggplot2)
setwd("~/PoD/Y2.1/NMSM/exercises/")

data_012 <- melt(
  fread("out/012.csv"),
  measure.vars = measure(exponent = as.integer, pattern = "n(\\d)"),
)
curves_012 <- data.table(
  exponent = rep(unique(data_012$exponent), each = 1000),
  x = rep(seq(0, 1, length.out = 1000), 2)
)[, y := (exponent + 1) * x^exponent]

ggplot(data_012) +
  geom_histogram(
    aes(value, after_stat(density)),
    alpha = 0.5,
    bins = 100,
    boundary = 0,
    position = "identity",
  ) +
  geom_line(aes(x, y), data = curves_012) +
  facet_wrap(
    vars(exponent),
    nrow = 2,
    labeller = as_labeller(
      \(n) sprintf("%d<i>x</i><sup>%s</sup>", as.integer(n) + 1, n)
    ),
  ) +
  labs(x = "<i>x</i>", y = "Density") +
  theme(
    strip.text = ggtext::element_markdown(),
    axis.title.x = ggtext::element_markdown(),
  )
