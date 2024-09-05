setwd("~/PoD/Y2.1/NMSM/exercises")
source("src/preamble.R")

L <- 50L
delta_swap <- 10L
num_steps <- 2.5e5L
num_chains <- 9
min_beta <- 0.42
max_beta <- 0.47
betas <- seq(min_beta, max_beta, length.out = num_chains)

system(
  sprintf(
    "exe/062_ising_mmc %g_%g_%d %d %g %g %d %d %d",
    min_beta, max_beta, num_chains,
    L, min_beta, max_beta, num_chains,
    delta_swap, num_steps
  )
)

fname <- sprintf("out/062_%g_%g_%d.csv", min_beta, max_beta, num_chains)

# Equilibration check
fread(fname) |>
  _[1:2e4, .SD, .SDcols = patterns("energy")] |>
  _[, iter := 1:.N] |>
  melt("iter", measure(value.name, chain = as.factor, sep = ".")) |>
  _[, energy := energy / L^2] |>
  ggplot(aes(iter, energy)) +
    geom_line() +
    facet_wrap(vars(chain)) +
    labs(x = "Time step", y = "Energy per spin")

eqdata <- fread(fname)[1001:.N]

swaps <- eqdata |>
  _[, .SD, .SDcols = patterns("swap")] |>
  setnames(c("c1", "c2")) |>
  na.omit()
# Total swapping rate
message(sum(swaps[[1]] > 0) / nrow(swaps))

Tc <- 2 / log(1 + sqrt(2))
swaps[c1 > 0, .(N = 100 * .N / nrow(swaps)), keyby = .(c1, c2)] |>
  ggplot() +
    geom_vline(aes(xintercept = 1 / Tc), linetype = "dashed") +
    geom_hline(aes(yintercept = 1 / Tc), linetype = "dashed") +
    geom_tile(aes(c1, c2, fill = N)) +
    scale_x_continuous(breaks = betas, labels = signif(betas, 3)) +
    scale_y_continuous(breaks = betas, labels = signif(betas, 3)) +
    scale_fill_viridis_c() +
    labs(x = "<i>β</i>", y = "<i>β</i>", fill = "Percentage") +
    theme(axis.title = ggtext::element_markdown())

eqdata |>
  _[, iter := 1:.N] |>
  melt(
    id.vars = "iter",
    measure.vars = measure(
      value.name, chain = as.factor, pattern = "(energy|beta).([0-9]+)"
    )
  ) |>
  _[, let(energy = energy / 50^2, temp = as.factor(signif(1 / beta, 3)))] |>
  ggplot() +
    geom_histogram(
      aes(energy, after_stat(density), fill = temp),
      position = "identity",
      boundary = 0,
      binwidth = 0.015
    ) +
    scale_fill_viridis_d() +
    labs(x = "Energy per spin", y = "Density", fill = "Temperature")

# Replicate the simulation without swaps
# system(
#   sprintf(
#     "exe/062_ising_mmc %g_%g_%d_ns %d %g %g %d %d %d",
#     min_beta, max_beta, num_chains,
#     L, min_beta, max_beta, num_chains,
#     num_steps + 2, # delta_swap > num_steps ==> no swaps
#     num_steps
#   )
# )

fname_ns <- sprintf("out/062_%g_%g_%d_ns.csv", min_beta, max_beta, num_chains)

# Equilibration check
fread(fname_ns) |>
  _[1:2e4, .SD, .SDcols = patterns("energy")] |>
  _[, iter := 1:.N] |>
  melt("iter", measure(value.name, chain = as.factor, sep = ".")) |>
  _[, energy := energy / L^2] |>
  ggplot(aes(iter, energy)) +
    geom_line() +
    facet_wrap(vars(chain)) +
    labs(x = "Time step", y = "Energy per spin")

eqdata_ns <- fread(fname_ns)[1001:.N]

get_tau <- function(x, max_lag = NULL) {
  acf <- acf_fft(x, max_lag)
  return(sum((1 - seq_along(acf) / length(x)) * acf))
}

magnets <- melt(
  eqdata[, iter := 1:.N],
  id.vars = "iter",
  measure.vars = measure(
    value.name, chain = as.factor, pattern = "(magnet|beta).([0-9]+)"
  )
)
magnets_ns <- melt(
  eqdata_ns[, iter := 1:.N],
  id.vars = "iter",
  measure.vars = measure(
    value.name, chain = as.factor, pattern = "(magnet|beta).([0-9]+)"
  )
)

magnets[, get_tau(magnet), keyby = beta]

energies[iter < 50000][beta == 0.46375, plot(energy, type = "l")]
