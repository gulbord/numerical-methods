wd <- unlist(strsplit(getwd(), "/"))
src <- match("src", wd)
if (!is.na(src))
  setwd(paste(wd[1:(src - 1)], collapse = "/"))
source("src/preamble.R")

# system("exe/031_crude_vs_importance 500 10000 80 500")

df <- fread("out/031.csv") |>
  melt(id.vars = "n", variable.name = "method") |>
  _[, value := abs(1 - value / 0.25)] |>
  _[, .(mean = mean(value), sd = sd(value)), by = .(n, method)]
levels(df$method) <- c("Crude", "Importance")

plt <- ggplot(df) +
  geom_ribbon(
    aes(n, ymin = mean - sd, ymax = mean + sd, fill = method),
    alpha = 0.5,
  ) +
  geom_line(aes(n, mean, colour = method)) +
  scale_colour_brewer(palette = "Dark2") +
  scale_fill_brewer(palette = "Dark2") +
  scale_x_continuous(breaks = scales::pretty_breaks()) +
  scale_y_continuous(breaks = scales::pretty_breaks()) +
  labs(
    x = "Number of samples",
    y = "Relative error (%)",
    colour = "Method",
    fill = "Method"
  )

plot_tex("031", plt, asp_ratio = 5 / 3, scale_factor = 0.9)
