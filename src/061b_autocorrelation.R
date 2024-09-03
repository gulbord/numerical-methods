setwd("~/PoD/Y2.1/NMSM/exercises")
source("src/preamble.R")

acf_fft <- function(x, max_lag = NULL, thr = 0) {
  x <- x - mean(x)

  # Pad with zeros to correct cyclicity
  len <- length(x)
  x_pad <- c(x, rep.int(0L, len))
  
  # fft and inverse
  fft <- fftwtools::fftw(x_pad)
  acf <- fftwtools::fftw(abs(fft)^2, inverse = 1)

  # Do the same on a 'mask' of ones to estimate the error
  mask <- fftwtools::fftw(c(rep.int(1L, len), rep.int(0L, len))) 
  err <- fftwtools::fftw(abs(mask)^2, inverse = 1)

  # Normalize with error and variance
  acf <- Re(acf / err)
  var <- acf[1]

  if (!is.null(max_lag))
    return(acf[min(max_lag, len)] / var)

  acf <- acf / var

  return(acf[1:which.max(acf < thr)])
}

lat_sides <- round(exp(seq(log(10), log(50), length.out = 6)))
num_steps <- 5e5
Tc <- 2 / log(1 + sqrt(2))

for (L in lat_sides) {
  message(paste("Running Metropolis for L =", L))
  system(sprintf(
    "exe/051_metropolis %s%d %d %f %d",
    "acor_L", L, L, Tc, num_steps
  ))
  message(paste("Running Wolff for L =", L))
  system(sprintf(
    "exe/061_wolff %s%d %d %f %d",
    "acor_L", L, L, Tc, num_steps
  ))
}

get_tau <- function(L, eqtime) {
  metro <- fread(paste0("out/051_acor_L", L, ".csv"))[eqtime:.N][, .SD / L^2]
  wolff <- fread(paste0("out/061_acor_L", L, ".csv"))[eqtime:.N]
  avg_cs <- mean(wolff$clus_size)
  wolff[, let(energy = energy / L^2, magnet = magnet / L^2, clus_size = NULL)]
  N <- nrow(metro) - 1

  res <- lapply(
    cbind(metro = metro, wolff = wolff),
    function(x) {
      acf <- acf_fft(x)
      tau <- sum((1 - seq_along(acf) / N) * acf)
      return(tau)
    }
  )

  for (j in grep("wolff", colnames(res)))
    set(res, j = j, value = res[[j]] * avg_cs / L^2)

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
  _[, algorithm := factor(
    algorithm,
    levels = c("metro", "wolff"),
    labels = c("Metropolis", "Wolff")
  )] |>
  ggplot(aes(lat_side, value, colour = algorithm, fill = algorithm)) +
    geom_point(size = 1) +
    scale_x_log10(guide = "axis_logticks") +
    scale_y_log10(guide = "axis_logticks") +
    scale_colour_brewer(palette = "Dark2") +
    scale_fill_brewer(palette = "Dark2") +
    geom_smooth(method = "lm", formula = y ~ x, linewidth = 0.5) +
    facet_wrap(
      vars(variable),
      nrow = 2,
      scale = "free_y",
      labeller = as_labeller(c(energy = "Energy", magnet = "Magnetization")),
    ) +
    labs(
      x = "Lattice size",
      y = "Autocorrelation time",
      colour = "Algorithm",
      fill = "Algorithm",
    )

plot_tex("061d", plt, asp_ratio = 1, scale_factor = 0.75)

taus |>
  melt(
    id.vars = "lat_side",
    measure.vars = measure(algorithm, variable, sep = ".")
  ) |>
  _[, as.list(coef(lm(log(value) ~ log(lat_side)))),
    , by = .(algorithm, variable)]
