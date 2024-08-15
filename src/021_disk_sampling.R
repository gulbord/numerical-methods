library(data.table)
library(ggplot2)
setwd("~/PoD/Y2.1/NMSM/exercises/")

# system("exe/021_disk_sampling 50000")
fread("out/021.csv") |>
  melt(
    id.vars = "theta",
    measure.vars = measure(r_type, pattern = "r_(.*)"),
    value.name = "radius",
  ) |>
  _[, r_type := factor(
    r_type,
    levels = c("naive", "correct"),
    labels = c("Naïve", "Correct")
  )] |>
  ggplot(aes(radius * cos(theta), radius * sin(theta))) +
    geom_point(alpha = 0.1) +
    facet_wrap(vars(r_type), nrow = 2) +
    labs(x = "<i>x</i>", y = "<i>y</i>") +
    theme(axis.title = ggtext::element_markdown())
