setwd("~/PoD/Y2.1/NMSM/exercises")
source("src/preamble.R")

L <- 50L
N <- L * L
num_steps <- 5e5L
Tc <- 2 / log(1 + sqrt(2))
temps <- c(Tc / 2, Tc, 2 * Tc)
temp_names <- c("low", "crit", "high")

# for (i in seq_along(temps)) {
#   argv <- sprintf(
#     "exe/061_ising_wolff %s %d %g %d",
#     temp_names[i], L, temps[i], num_steps
#   )
#   system(argv)
# }

plt <- lapply(
  temp_names,
  function(f) {
    df <- fread(sprintf("out/061_%s.csv", f), select = "clus_size")
    h <- hist(df$clus_size, breaks = "FD", plot = FALSE)

    mask <- h$counts > 0
    x <- h$mids[mask]
    y <- h$counts[mask]
    err <- sqrt(y)

    ggplot(data.table(x, y, err)) +
      geom_pointrange(
        aes(x, y, ymin = y - err, ymax = y + err),
        size = 0.04,
        linewidth = 0.4,
      ) +
      scale_y_log10(guide = "axis_logticks") +
      labs(x = "Cluster size", y = "Count")
  }
)

plot_tex("061a", plt[[1]], asp_ratio = 4 / 3, scale_factor = 0.75)
plot_tex("061b", plt[[2]], asp_ratio = 4 / 3, scale_factor = 0.75)
plot_tex("061c", plt[[3]], asp_ratio = 4 / 3, scale_factor = 0.75)
