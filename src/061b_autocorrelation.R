wd <- unlist(strsplit(getwd(), "/"))
src <- match("src", wd)
if (!is.na(src))
  setwd(paste(wd[1:(src - 1)], collapse = "/"))
source("src/preamble.R")

lat_sides <- round(exp(seq(log(10), log(50), length.out = 6)))
num_steps <- 1e6L
Tc <- 2 / log(1 + sqrt(2))

# for (L in lat_sides) {
#   message(paste("Running Metropolis for L =", L))
#   system(sprintf(
#     "exe/051_ising_metropolis %s%d %d %f %d",
#     "acor_L", L, L, Tc, num_steps
#   ))
#   message(paste("Running Wolff for L =", L))
#   system(sprintf(
#     "exe/061_ising_wolff %s%d %d %f %d",
#     "acor_L", L, L, Tc, num_steps
#   ))
# }

get_tau <- function(L, eqtime) {
  metro <- fread(paste0("out/051_acor_L", L, ".csv"))[eqtime:.N]
  metro[, magnet := abs(magnet)]

  wolff <- fread(paste0("out/061_acor_L", L, ".csv"))[eqtime:.N]
  avg_cs <- mean(wolff$clus_size)
  wolff[, let(clus_size = NULL, magnet = abs(magnet))]
  N <- nrow(metro)

  res <- lapply(
    cbind(metro = metro, wolff = wolff),
    function(x) {
      acf <- acf_fft(x, max_lag = 250, thr = 0.005)[-1]
      tau <- sum((N - seq_along(acf)) * acf / (N - 1))
      return(tau)
    }
  )

  res$wolff.energy <- res$wolff.energy * avg_cs / L^2
  res$wolff.magnet <- res$wolff.magnet * avg_cs / L^2

  return(res)
}

taus <- lapply(lat_sides, get_tau, eqtime = 1000L) |>
  rbindlist() |>
  _[, lat_side := lat_sides]

plt <- taus |>
  melt(
    id.vars = "lat_side",
    measure.vars = measure(algorithm, variable, sep = ".")
  ) |>
  _[, variable := factor(
    variable,
    levels = c("energy", "magnet"),
    labels = c("Energy", "Magnetization")
  )] |>
  ggplot(aes(lat_side, value, colour = variable, fill = variable)) +
    geom_point(size = 1) +
    scale_x_log10(guide = "axis_logticks") +
    scale_y_log10(guide = "axis_logticks") +
    scale_colour_brewer(palette = "Dark2") +
    scale_fill_brewer(palette = "Dark2") +
    geom_smooth(method = "lm", formula = y ~ x, linewidth = 0.5) +
    facet_wrap(
      vars(algorithm),
      nrow = 2,
      scale = "free_y",
      labeller = as_labeller(c(metro = "Metropolis", wolff = "Wolff")),
    ) +
    labs(
      x = "Lattice size",
      y = "Autocorrelation time",
      colour = "Observable",
      fill = "Observable",
    )

plot_tex("061d", plt, asp_ratio = 1, scale_factor = 0.75)

# Parameters
fits <- taus |>
  melt(
    id.vars = "lat_side",
    measure.vars = measure(algorithm, variable, sep = ".")
  ) |>
  _[, broom::tidy(lm(log(value) ~ log(lat_side)))
    , by = .(algorithm, variable)]

fwrite(fits, "src/data/061b_fits.csv")
