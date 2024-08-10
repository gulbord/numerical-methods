library(data.table)
library(ggplot2)
setwd("~/PoD/Y2.1/NMSM/exercises/")

plt <- lapply(
  c("out/011a.txt", "out/011b.txt"),
  function(file) {
    fread(file) |>
      setnames(1, "throws") |>
      melt(id.vars = "throws") |>
      _[, value := 100 * value] |>
      _[, .(mean = mean(value), sd = sd(value)), by = throws] |>
      ggplot(aes(throws, mean)) +
        geom_line() +
        geom_ribbon(aes(ymin = mean - sd, ymax = mean + sd), alpha = 0.5) +
        labs(x = "Number of throws", y = "Percentage error (%)")
  }
)
