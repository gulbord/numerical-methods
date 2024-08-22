library(data.table)
library(ggplot2)
setwd("~/PoD/Y2.1/NMSM/exercises")

writeLines(
  c(
    "# Leave whitespace between keyword and value",
    "num_particles 100",
    "density 0.1",
    "disp_max 0.1",
    "temperature 1",
    "mc_steps 1000000",
    "init_type random",
    "realizations 10"
  ),
  "src/083.cfg"
)

system("rm out/083*.csv")
for (rho in c(0.05, 0.3, 0.5, 1)) {
  for (dmax in c(0.01, 0.1, 0.3, 0.6, 1)) {
    message(sprintf("Processing density = %g, disp_max = %g", rho, dmax))
    system("sed -i 's/init_type .*/init_type random/' src/083.cfg")
    system(sprintf("sed -i 's/density .*/density %g/' src/083.cfg", rho))
    system(sprintf("sed -i 's/disp_max .*/disp_max %g/' src/083.cfg", dmax))
    system("exe/083_hard_spheres_mc src/083.cfg")
    system("sed -i 's/init_type .*/init_type cubic/' src/083.cfg")
    system("exe/083_hard_spheres_mc src/083.cfg")
  }
}

plot_obs <- function(fname) {
  df <- fread(fname) |>
    _[, iter := 1:.N, by = realization] |>
    _[, energy := energy / 1000] |>
    _[, c(mean = lapply(.SD, mean), sd = lapply(.SD, sd))
      , keyby = iter, .SDcols = !"realization"] |>
    setnames(
      -1, c("acc_ratio.mean", "energy.mean", "acc_ratio.sd", "energy.sd")
    ) |>
    melt(
      id.vars = "iter",
      measure.vars = measure(variable, value.name, sep = ".")
    )

  box_side <- fname |>
    stringr::str_extract("(?<=L)[0-9.]+") |>
    as.numeric()
  disp_max <- fname |>
    stringr::str_extract("(?<=d)[0-9.]+") |>
    as.numeric()

  ggplot(df) +
    geom_ribbon(
      aes(iter, ymin = mean - sd, ymax = mean + sd),
      alpha = 0.5,
      ) +
    geom_line(aes(iter, mean)) +
    facet_wrap(
      vars(variable),
      nrow = 2,
      scales = "free_y",
      labeller = as_labeller(c(
        acc_ratio = "Acceptance ratio",
        energy = "Number of overlaps"
      ))
    ) +
    labs(
      x = "Monte Carlo sweeps",
      y = "Average over 10 realizations",
      title = sprintf(
        "Density %g, Max. displacement %g",
        round(100 / box_side^3, 1), disp_max
      )
    )
}
