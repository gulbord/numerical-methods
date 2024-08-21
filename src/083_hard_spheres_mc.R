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
    "mc_steps 10000",
    "init_type random",
    "realizations 10"
  ),
  "src/083.cfg"
)

disp_max <- 10^seq(log10(0.01), log10(1), length.out = 10)
density <- c(0.05, 0.3, 0.5, 1)

for (rho in c(0.05, 0.3, 0.5, 1)) {
  for (dmax in 10^seq(log10(0.01), log10(1), length.out = 10)) {
    message(sprintf("Processing density = %g, disp_max = %g", rho, dmax))
    system(sprintf("sed -i 's/density .*/density %g/' src/083.cfg", rho))
    system(sprintf("sed -i 's/disp_max .*/disp_max %g/' src/083.cfg", dmax))
    system("exe/083_hard_spheres_mc src/083.cfg")
  }
}
