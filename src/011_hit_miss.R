library(data.table)
library(ggplot2)
setwd("~/PoD/Y2.1/NMSM/exercises/")

# system("exe/011a_rect_hit_miss 1000 100 10")
# system("exe/011b_disk_hit_miss 1000 100 10")
plt <- lapply(
  c("out/011a.csv", "out/011b.csv"),
  function(file) {
    fread(file) |>
      _[, error := 100 * error] |>
      _[, .(mean = mean(error), sd = sd(error)), by = throws] |>
      ggplot(aes(throws, mean)) +
        geom_line() +
        geom_ribbon(aes(ymin = mean - sd, ymax = mean + sd), alpha = 0.5) +
        labs(x = "Number of throws", y = "Percentage error (%)")
  }
)
