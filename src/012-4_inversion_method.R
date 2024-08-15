library(data.table)
library(ggplot2)
setwd("~/PoD/Y2.1/NMSM/exercises/")

# system("exe/012_inversion_power34 50000")
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
    breaks = seq(0, 1, 0.01), 
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

# system("exe/013_inversion_power2 50000")
# system("exe/014a_inversion_exp 2 50000")
# system("exe/014b_inversion_exp2 50000")
# system("exe/014c_inversion_powerlaw 0.5 0.1 4 50000")
plts <- purrr::map2(
  c(
    "out/013.csv",
    "out/014a_mu2.csv",
    "out/014b.csv",
    "out/014c_a0.5_b0.1_n4.csv"
  ),
  c(
    \(x) 3 * x^2 / 8,
    \(x) 2 * exp(-2 * x),
    \(x) 2 * x * exp(-x^2),
    \(x) 0.0375 / (0.5 + 0.1 * x)^4
  ),
  function(file, fun) {
    fread(file, col.names = "x") |>
      _[x < 20] |>
      ggplot() +
        geom_histogram(
          aes(x, after_stat(density)),
          alpha = 0.5,
          boundary = 0,
          binwidth = \(x) 2 * IQR(x) / length(x)^(1 / 3),
        ) +
        geom_function(fun = fun) +
        labs(x = "<i>x</i>", y = "Density") +
        theme(axis.title.x = ggtext::element_markdown())
  }
)
