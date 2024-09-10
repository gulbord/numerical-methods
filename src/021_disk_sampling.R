wd <- unlist(strsplit(getwd(), "/"))
src <- match("src", wd)
if (!is.na(src))
  setwd(paste(wd[1:(src - 1)], collapse = "/"))
source("src/preamble.R")

# system("exe/021_disk_sampling 50000")
plt <- fread("out/021.csv") |>
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
    geom_point(alpha = 0.1, size = 0.08) +
    facet_wrap(vars(r_type), ncol = 2) +
    labs(x = "<i>x</i>", y = "<i>y</i>") +
    theme(axis.title = ggtext::element_markdown())

plot_tex("021", plt, asp_ratio = 9 / 5, scale_factor = 0.9)
