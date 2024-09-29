wd <- unlist(strsplit(getwd(), "/"))
src <- match("src", wd)
if (!is.na(src))
  setwd(paste(wd[1:(src - 1)], collapse = "/"))
source("src/preamble.R")

# Solve the self-consistent equations for the partition function
scpf <- function(betas, energies, counts, tol = 1e-7, max_iter = 1000) {
  M <- length(betas)
  z_old <- rep(10, M)
  nums <- rowSums(counts)

  iter <- 1
  repeat {
    #message(paste("Iteration", iter))
    iter <- iter + 1

    z_old <- z_old / sqrt(min(z_old) * max(z_old))
    lz_old <- log(z_old)
    z_new <- rep(0, M)

    z_new <- vapply(
      betas,
      function(b) {
        sum(
          vapply(
            seq_along(energies)[nums > 0],
            function(i) {
              denom <- exp((b - betas[1]) * energies[i] - lz_old[1]) *
                sum(exp((betas[1] - betas) * energies[i] - lz_old + lz_old[1]))
              return(nums[i] / denom)
            },
            numeric(1)
          )
        )
      },
      numeric(1)
    )

    if (iter == max_iter || sum((1 - z_old / z_new)^2) < tol)
      break

    z_old <- z_new
  }

  return(z_new)
}

eq_time <- 1e4
fnames <- list.files("out", pattern = "051_shm", full.names = TRUE)
samples <- fnames |>
  lapply(\(f) fread(f)[(eq_time + 1):.N, energy]) |>
  do.call(cbind, args = _)
betas <- 1 / as.numeric(sub(".*T([.0-9]+).csv", "\\1", fnames))

energy_breaks <- seq(min(samples), max(samples) + 1) - 0.5
energies <- seq(min(samples), max(samples))
counts <- apply(
  samples,
  MARGIN = 2,
  FUN = \(x) hist(x, breaks = energy_breaks, plot = FALSE)$counts
) / dim(samples)[1]

scpf(betas, energies, counts, max_iter = 200)
