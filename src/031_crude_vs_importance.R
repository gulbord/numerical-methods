setwd("~/PoD/Y2.1/NMSM/exercises")
source("src/preamble.R")

# system("exe/031_crude_vs_importance 500 10000 80 500")

data_031 <- fread("out/031.csv") |>
  melt(id.vars = "n", variable.name = "method") |>
  _[, .(mean = mean(value), sd = sd(value)), by = .(n, method)]
levels(data_031$method) <- c("Crude", "Importance")

plt_031 <- ggplot(data_031) +
  geom_ribbon(
    aes(n, ymin = mean - sd, ymax = mean + sd, fill = method),
    alpha = 0.5,
    ) +
  geom_line(aes(n, mean, colour = method)) +
  scale_colour_brewer(palette = "Dark2") +
  scale_fill_brewer(palette = "Dark2") +
  labs(
    x = "Number of samples",
    y = "Relative error (%)",
    colour = "Method",
    fill = "Method"
  )

plot_tex("031", plt_031, asp_ratio = 5 / 3, scale_factor = 0.9)
