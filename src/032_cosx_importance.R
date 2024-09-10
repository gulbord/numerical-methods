wd <- unlist(strsplit(getwd(), "/"))
src <- match("src", wd)
if (!is.na(src))
  setwd(paste(wd[1:(src - 1)], collapse = "/"))
source("src/preamble.R")

# system("exe/032_cosx_importance 10 1000 10 500")

plt <- fread("out/032.csv") |>
  _[, integral := 100 * abs(1 - integral)] |> # True value is 1
  _[, .(mean = mean(integral), sd = sd(integral)), by = n] |>
  ggplot() +
    geom_ribbon(
      aes(n, ymin = mean - sd, ymax = mean + sd),
      alpha = 0.5,
    ) +
    scale_x_continuous(breaks = scales::pretty_breaks()) +
    scale_y_continuous(breaks = scales::pretty_breaks()) +
    geom_line(aes(n, mean)) +
    labs(x = "Number of samples", y = "Relative error (%)")

plot_tex("032", plt, asp_ratio = 4 / 3, scale_factor = 0.75)
