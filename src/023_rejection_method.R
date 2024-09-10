wd <- unlist(strsplit(getwd(), "/"))
src <- match("src", wd)
if (!is.na(src))
  setwd(paste(wd[1:(src - 1)], collapse = "/"))
source("src/preamble.R")

# system("exe/023a_rejection_sampling 50000")

plt_smp <- read.csv("out/023a.csv", col.names = "x") |>
  ggplot() +
    geom_histogram(
      aes(x, after_stat(density)),
      alpha = 0.5,
      boundary = 0,
      binwidth = \(x) 2 * IQR(x) / length(x)^(1 / 3),
    ) +
    geom_function(fun = \(x) 2 * exp(-x^2) / sqrt(pi)) +
    labs(x = "Sampled value", y = "Density")

plot_tex("023a", plt_smp, asp_ratio = 4 / 3, scale_factor = 0.75)

# system("exe/023b_rejection_accratio 5 5000 100000")

plt_acc <- read.csv("out/023b.csv") |>
  ggplot() +
    geom_line(aes(p, acc)) +
    labs(x = "<i>p</i>", y = "Acceptance ratio") +
    theme(axis.title.x = ggtext::element_markdown())

plot_tex("023b", plt_acc, asp_ratio = 4 / 3, scale_factor = 0.75)
