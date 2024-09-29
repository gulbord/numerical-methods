wd <- unlist(strsplit(getwd(), "/"))
src <- match("src", wd)
if (!is.na(src))
  setwd(paste(wd[1:(src - 1)], collapse = "/"))
source("src/preamble.R")

# Solve the self-consistent equations for the partition function
scpf <- function(betas, energies, counts, taus, tol = 1e-7, max_iter = NULL) {
  M <- length(betas)
  logN <- log(colSums(counts) / taus)
  nums <- colSums(t(counts) / taus)
  z_old <- rep(1, M)

  iter <- 1
  repeat {
    iter <- iter + 1
    logz <- log(z_old)
    z_new <- rep(0, M)

    z_new <- vapply(
      betas,
      function(b) {
        sum(
          vapply(
            seq_along(energies)[nums > 0],
            function(i) {
              denom <- exp(
                logN[1] - logz[1] + (b - betas[1]) * energies[i]
              ) * sum(
                exp(
                  logN - logN[1] - logz + logz[1] +
                    (betas[1] - betas) * energies[i]
                )
              )
              return(nums[i] / denom)
            },
            numeric(1)
          )
        )
      },
      numeric(1)
    )

    last_iter <- !is.null(max_iter) && iter == max_iter
    if (last_iter || sum((1 - z_old / z_new)^2) < tol)
      break

    z_old <- z_new / sqrt(min(z_new) * max(z_new))
  }

  return(z_new)
}

eq_time <- 1e4
fnames <- list.files("out", pattern = "051_shm", full.names = TRUE)
samples <- fnames |>
  lapply(\(f) fread(f)[(eq_time + 1):.N, energy]) |>
  do.call(cbind, args = _)
betas <- 1 / as.numeric(sub(".*T([.0-9]+).csv", "\\1", fnames))
taus <- apply(
  samples,
  MARGIN = 2,
  FUN = function(x) {
    acf <- acf_fft(x, max_lag = 250, thr = 0.005)[-1]
    return(sum((1 - seq_along(acf) / length(x)) * acf))
  }
)

energy_breaks <- seq(min(samples), max(samples) + 1) - 0.5
energies <- seq(min(samples), max(samples))
counts <- apply(
  samples,
  MARGIN = 2,
  FUN = \(x) hist(x, breaks = energy_breaks, plot = FALSE)$counts
)

L <- 100
Z <- scpf(betas, energies, counts, taus)

logN <- log(colSums(counts) / taus)
nums <- colSums(t(counts) / taus)
U <- vapply(
  betas,
  function(b) {
    sum(
      vapply(
        seq_along(energies)[nums > 0],
        function(i) {
          denom <- exp(
            logN[1] - log(Z[1]) + (b - betas[1]) * energies[i]
          ) * sum(
            exp(
              logN - logN[1] - log(Z) + log(Z[1]) +
                (betas[1] - betas) * energies[i]
            )
          )
          return(energies[i] * nums[i] / denom)
        },
        numeric(1)
      )
    )
  },
  numeric(1)
) / (Z * L^2)

get_meanrange <- function(x) {
  N <- length(x)
  acf <- acf_fft(x, max_lag = 250, thr = 0.005)[-1]
  tau <- sum((1 - seq_along(acf) / N) * acf)
  return(list(mean = mean(x), sd = sd(x) * sqrt((N - 1) / (N - 1 - 2 * tau))))
}

Udata <- data.table(samples) |>
  melt(
    measure.vars = measure(
      temp = \(x) 1 / betas[as.integer(x)],
      pattern = "V(.*)"
    ),
    value.name = "energy",
  ) |>
  _[, get_meanrange(energy / L^2), by = temp] |>
  _[, mhm := U]

plt_U <- ggplot(Udata) +
  geom_line(aes(temp, mhm), linewidth = 0.35) +
  geom_pointrange(
    aes(temp, mean, ymin = mean - sd, ymax = mean + sd),
    linewidth = 0.35,
    size = 0.07,
  ) +
  scale_x_continuous(breaks = scales::pretty_breaks()) +
  scale_y_continuous(breaks = scales::pretty_breaks()) +
  labs(
    x = "Temperature",
    y = "Energy per spin",
  )

plot_tex("123a", plt_U, asp_ratio = 4 / 3, scale_factor = 0.8)

# Second part of the analysis
