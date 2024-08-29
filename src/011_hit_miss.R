setwd("~/PoD/Y2.1/NMSM/exercises")
source("src/preamble.R")

system("exe/011a_rect_hit_miss 1000 100 100")
system("exe/011b_disk_hit_miss 1000 100 100")

plt <- list(rect = fread("out/011a.csv"), disk = fread("out/011b.csv")) |>
  rbindlist(idcol = "id") |>
  _[, let(id = factor(id, levels = c("rect", "disk"),
          labels = c("Rectangle", "Disk")), error = 100 * error)] |>
  _[, .(mean = mean(error), sd = sd(error)), by = .(id, throws)] |>
  ggplot(aes(throws, mean)) +
    geom_line() +
    geom_ribbon(aes(ymin = mean - sd, ymax = mean + sd), alpha = 0.5) +
    facet_wrap(vars(id), ncol = 1, scales = "free_y") +
    labs(x = "Number of throws", y = "Percentage error (%)")

plot_tex("011", plt, asp_ratio = 1, scale_factor = 0.75)
