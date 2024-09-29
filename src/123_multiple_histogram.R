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

# plot_tex("123a", plt_U, asp_ratio = 4 / 3, scale_factor = 0.8)

Tc <- 2 / log(1 + sqrt(2))
temp_step <- 0.005
num_temps <- 60
temps <- c(
  seq(to = Tc - temp_step, by = temp_step, length.out = num_temps %/% 2),
  seq(from = Tc, by = temp_step, length.out = num_temps - num_temps %/% 2)
)
L <- c(32, 45, 64, 90)

eq_time <- 1e4
reweigh <- parallel::mclapply(
  c(32, 45, 64, 90),
  function(L) {
    fnames <- sprintf("out/051_L%d_T%g.csv", L, temps)
    samples <- fnames |>
      lapply(\(f) fread(f)[(eq_time + 1):.N, energy]) |>
      do.call(cbind, args = _)
    betas <- 1 / temps
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

    Z <- scpf(betas, energies, counts, taus, max_iter = 1000)
    message(paste("Computed Z for L =", L))

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
    ) / Z

    U2 <- vapply(
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
              return(energies[i]^2 * nums[i] / denom)
            },
            numeric(1)
          )
        )
      },
      numeric(1)
    ) / Z

    C <- temps^2 * (U2 - U^2) / L^2

    return(list(energy = U / L^2, spheat = C))
  },
  mc.cores = min(4, getDTthreads())
) |>
  rbindlist(idcol = "L") |>
  _[, let(temp = rep(temps, 4), L = c(32, 45, 64, 90)[L])] |>
  _[, .(L, temp, energy, spheat)]

# fwrite(rew[, .(L, temp, energy, spheat)], "src/data/123_reweighting.csv")
reweigh <- fread("src/data/123_reweighting.csv")

real_data <- parallel::mclapply(
  c(32, 45, 64, 90),
  function(L) {
    res <- lapply(
      temps,
      function(t) {
        fname <- sprintf("out/051_L%d_T%g.csv", L, t)
        energy <- fread(fname)[(eq_time + 1):.N, energy / L^2]

        N <- length(energy)
        acf <- acf_fft(energy, max_lag = 250, thr = 0.005)[-1]
        tau <- sum((1 - seq_along(acf) / N) * acf)

        return(
          list(
            L = L,
            temp = t,
            energy = mean(energy),
            spheat = var(energy) * (t * L)^2 * (N - 1) / (N - 1 - 2 * tau)
          )
        )
      }
    )
    return(rbindlist(res))
  },
  mc.cores = min(4, getDTthreads())
) |> rbindlist()

# fwrite(real_data, "src/data/123_real_data.csv")
# real_data <- fread("src/data/123_real_data.csv")
