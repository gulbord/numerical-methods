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
num_steps <- 5e4
Tc <- 2 / log(1 + sqrt(2))

for (L in lat_sides) {
  message(paste("Running Metropolis for L =", L))
  system(sprintf(
    "exe/051_metropolis %s%d %d %f %d",
    "acor_L", L, L, Tc, min(1e7L, num_steps * L^2)
  ))
  message(paste("Running Wolff for L =", L))
  system(sprintf(
    "exe/061_wolff %s%d %d %f %d",
    "acor_L", L, L, Tc, num_steps
  ))
}

eqtime <- 500L # Manual analysis

get_tau <- function(L) {
  df <- fread(paste0("out/061_acor_L", L, ".csv")) |>
    _[eqtime:.N] |>
    _[, let(energy = energy / L^2, magnet = magnet / L^2)]
  
  avg_cs <- mean(df$clus_size)

  lapply(
    df[, .(energy, magnet)],
    function(x) {
        acf <- acf_fft(x)
        tau_data <- sum((1 - seq_along(acf) / (nrow(df) - eqtime)) * acf)
        return(tau_data * avg_cs / L^2)
    }
  )
}

taus <- lapply(lat_sides, get_tau) |>
  rbindlist() |>
  _[, lat_side := lat_sides]

taus |>
  melt(id.vars = "lat_side") |>
  ggplot(aes(lat_side, value, colour = variable)) +
    geom_point() +
    geom_smooth(method = "lm", formula = y ~ x) +
    scale_x_log10() +
    scale_y_log10()
