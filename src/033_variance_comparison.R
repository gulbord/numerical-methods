setwd("~/PoD/Y2.1/NMSM/exercises")
source("src/preamble.R")

T <- seq(1, 20, length.out = 5000)
var_rho <- function(t) sqrt(exp(t) - 1)
var_g <- function(t) {
  a <- (1 + t - sqrt(1 + t^2)) / t
  return(sqrt(exp(a * t) / (a * (2 - a)) - 1))
}

plt <- ggplot() +
  geom_line(aes(T, var_rho(T) / var_g(T))) +
  scale_x_continuous(breaks = scales::pretty_breaks()) +
  scale_y_continuous(breaks = scales::pretty_breaks()) +
  labs(x = "<i>T</i>", y = "Variance ratio") +
  theme(axis.title.x = ggtext::element_markdown())

plot_tex("033", plt, asp_ratio = 4 / 3, scale_factor = 0.75)
