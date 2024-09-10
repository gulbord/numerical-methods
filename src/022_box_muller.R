wd <- unlist(strsplit(getwd(), "/"))
src <- match("src", wd)
if (!is.na(src))
  setwd(paste(wd[1:(src - 1)], collapse = "/"))
source("src/preamble.R")

# system("exe/022_box_muller 1 2 50000")
plt <- fread("out/022_mu1_sigma2.csv") |>
  melt(measure.vars = 1:2) |>
  ggplot() +
    geom_histogram(
      aes(value, after_stat(density)),
      alpha = 0.5,
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

plot_tex("022", plt, asp_ratio = 1, scale_factor = 0.75)
