wd <- unlist(strsplit(getwd(), "/"))
src <- match("src", wd)
if (!is.na(src))
  setwd(paste(wd[1:(src - 1)], collapse = "/"))
source("src/preamble.R")

L <- 50L
delta_swap <- 5L
num_steps <- 1e5L
num_chains <- 6L
min_temp <- 2.0
max_temp <- 2.5
temps <- seq(min_temp, max_temp, length.out = num_chains)

system(
  sprintf(
    "exe/062_ising_mmc %g_%g_%d %d %g %g %d %d %d",
    min_temp, max_temp, num_chains,
    L, min_temp, max_temp, num_chains,
    delta_swap, num_steps
  )
)

fname <- sprintf("out/062_%g_%g_%d.csv", min_temp, max_temp, num_chains)

# Equilibration check
plt_eq <- fread(fname)[1:2e4] |>
  _[, iter := 1:.N] |>
  melt("iter", measure(value.name, chain, pattern = "(energy).(.+)")) |>
  _[, energy := energy / L^2] |>
  ggplot() +
    geom_line(aes(iter, energy, colour = as.factor(chain), group = 1)) +
    scale_colour_viridis_d() +
    facet_wrap(vars(chain), ncol = 2) +
    labs(x = "Time step", y = "Energy per spin", colour = "Temperature") +
    theme(legend.position = "bottom")

plot_tex("062a", plt_eq, asp_ratio = 1, scale_factor = 1)

eq_data <- fread(fname)[1001:.N][, iter := 1:.N]

swaps <- eq_data |>
  _[, .SD, .SDcols = patterns("swap")] |>
  setnames(c("c1", "c2")) |>
  na.omit()
# Total swapping rate
message(sum(swaps[[1]] >= 0) / nrow(swaps))

Tc <- 2 / log(1 + sqrt(2))
swaps[c1 >= 0, .(N = 100 * .N / nrow(swaps)), keyby = .(c1, c2)] |>
  _[, let(c1 = temps[c1 + 1], c2 = temps[c2 + 1])] |>
  ggplot() +
    geom_vline(aes(xintercept = Tc), linetype = "dashed") +
    geom_hline(aes(yintercept = Tc), linetype = "dashed") +
    geom_tile(aes(c1, c2, fill = N)) +
    scale_x_continuous(
      breaks = c(Tc, temps),
      minor_breaks = NULL,
      labels = c("<i>T</i><sub>c</sub>", signif(temps, 3)),
    ) +
    scale_y_continuous(
      breaks = c(Tc, temps),
      minor_breaks = NULL,
      labels = c("<i>T</i><sub>c</sub>", signif(temps, 3)),
    ) +
    scale_fill_viridis_c() +
    labs(x = "Temperature", y = "Temperature", fill = "Percentage") +
    theme(axis.text = ggtext::element_markdown())

melt(
  eq_data,
  "iter",
  measure(value.name, chain = as.integer, pattern = "(energy).([0-9]+)")
) |>
  _[, let(energy = energy / L^2, chain = as.factor(temps[chain]))] |>
  ggplot() +
    geom_histogram(
      aes(energy, after_stat(density), fill = chain),
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
    min_temp, max_temp, num_chains,
    L, min_temp, max_temp, num_chains,
    num_steps + 2, # delta_swap > num_steps ==> no swaps
    num_steps
  )
)

fname_ns <- sprintf("out/062_%g_%g_%d_ns.csv", min_temp, max_temp, num_chains)

eq_data_ns <- fread(fname_ns)[1001:.N][, iter := 1:.N]

get_tau <- function(x, max_lag = NULL, thr = 0) {
  acf <- acf_fft(x, max_lag, thr)[-1]
  return(sum((1 - seq_along(acf) / length(x)) * acf))
}

energies <- melt(
  eq_data,
  "iter",
  measure(value.name, chain, pattern = "(energy).(.+)")
)
energies_ns <- melt(
  eq_data_ns,
  "iter",
  measure(value.name, chain, pattern = "(energy).(.+)")
)

taus <- energies[, get_tau(energy, max_lag = 250, thr = 0.005)
                 , by = chain]
taus_ns <- energies_ns[, get_tau(energy, max_lag = 250, thr = 0.005)
                       , by = chain]

merge(
  energies,
  energies_ns,
  by = c("iter", "chain"),
  suffixes = c(".mmc", ".single")
) |>
  melt(c("iter", "chain"), measure(value.name, algo, sep = ".")) |>
  _[, .(lag = 1:250, acf = acf_fft(energy, max_lag = 250, thr = NULL))
    , keyby = .(algo, chain)] |>
  ggplot() +
    geom_line(aes(lag, acf, colour = algo)) +
    facet_wrap(
      vars(chain),
      ncol = 2,
      labeller = as_labeller(\(x) paste("<i>T</i> =", x))
    ) +
    scale_colour_brewer(
      palette = "Dark2",
      labels = c("Multiple chains", "Single chain"),
    ) +
    labs(x = "Lag", y = "Autocorrelation function", colour = "Algorithm") +
    theme(strip.text = ggtext::element_markdown(), legend.position = "bottom")
