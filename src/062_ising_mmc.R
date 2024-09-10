wd <- unlist(strsplit(getwd(), "/"))
src <- match("src", wd)
if (!is.na(src))
  setwd(paste(wd[1:(src - 1)], collapse = "/"))
source("src/preamble.R")

L <- 50L
delta_swap <- 20L
num_steps <- 1e5L
num_chains <- 6
min_beta <- 0.42
max_beta <- 0.48
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
plt_eq <- fread(fname)[1:2e4] |>
  _[, iter := 1:.N] |>
  melt("iter", measure(value.name, chain, pattern = "(energy|beta).(.+)")) |>
  _[, energy := energy / L^2] |>
  ggplot() +
    geom_line(aes(iter, energy, colour = as.factor(beta), group = 1)) +
    scale_colour_viridis_d() +
    facet_wrap(vars(chain), ncol = 2) +
    labs(x = "Time step", y = "Energy per spin", colour = "<i>β</i>") +
    theme(legend.position = "bottom", legend.title = ggtext::element_markdown())

plot_tex("062a", plt_eq, asp_ratio = 1, scale_factor = 1)

eqdata <- fread(fname)[1001:.N][, iter := 1:.N]

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

melt(
  eqdata,
  "iter",
  measure(value.name, chain, pattern = "(energy|beta).([0-9]+)")
) |>
  _[, let(energy = energy / L^2, temp = as.factor(signif(1 / beta, 3)))] |>
  ggplot() +
    geom_histogram(
      aes(energy, after_stat(density), fill = temp),
      position = "identity",
      boundary = 0,
      binwidth = 0.015,
      alpha = 0.75
    ) +
    scale_fill_viridis_d() +
    labs(x = "Energy per spin", y = "Density", fill = "Temperature")

# Replicate the simulation without swaps
system(
  sprintf(
    "exe/062_ising_mmc %g_%g_%d_ns %d %g %g %d %d %d",
    min_beta, max_beta, num_chains,
    L, min_beta, max_beta, num_chains,
    num_steps + 2, # delta_swap > num_steps ==> no swaps
    num_steps
  )
)

fname_ns <- sprintf("out/062_%g_%g_%d_ns.csv", min_beta, max_beta, num_chains)

eqdata_ns <- fread(fname_ns)[1001:.N][, iter := 1:.N]

get_tau <- function(x, max_lag = NULL, thr = 0) {
  acf <- acf_fft(x, max_lag, thr)
  return(sum((1 - seq_along(acf) / length(x)) * acf))
}

energies <- melt(
  eqdata,
  "iter",
  measure(value.name, chain, pattern = "(energy|beta).(.+)")
)
energies_ns <- melt(
  eqdata_ns,
  "iter",
  measure(value.name, chain, pattern = "(energy|beta).(.+)")
)

get_tau_lag <- function(x, max_lag) {
  lags <- 1:max_lag
  taus <- sapply(lags, \(m) get_tau(x, m))
  pick <- which.max(lags < 5 * taus) + 1
  return(list(max_lag = lags[pick], tau = taus[pick]))
}

taus <- energies[, get_tau(energy, thr = 0.001), keyby = beta, showProgress = TRUE]
taus_ns <- energies_ns[, get_tau(energy, thr = 0.001), keyby = beta, showProgress = TRUE]

merge(
  energies[, !"chain"],
  energies_ns[, !"chain"],
  by = c("iter", "beta"),
  suffixes = c(".mmc", ".single")
) |>
  melt(c("iter", "beta"), measure(value.name, algo, sep = ".")) |>
  _[, .(lag = 1:250, acf = acf_fft(energy, max_lag = 250)),
    keyby = .(algo, beta)] |>
  ggplot() +
    geom_line(aes(lag, acf, colour = algo)) +
    facet_wrap(
      vars(signif(1 / beta, 3)),
      ncol = 2,
      labeller = as_labeller(\(x) paste("<i>T</i> =", x))
    ) +
    scale_colour_brewer(
      palette = "Dark2",
      labels = c("Multiple chains", "Single chain"),
    ) +
    labs(x = "Lag", y = "Autocorrelation function", colour = "Algorithm") +
    theme(strip.text = ggtext::element_markdown(), legend.position = "bottom")
