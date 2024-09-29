wd <- unlist(strsplit(getwd(), "/"))
src <- match("src", wd)
if (!is.na(src))
  setwd(paste(wd[1:(src - 1)], collapse = "/"))
source("src/preamble.R")

L <- 50
delta_swap <- 10
num_steps <- 1e6
num_chains <- 6
min_temp <- 2.1
max_temp <- 2.4
temps <- seq(min_temp, max_temp, length.out = num_chains)

# system(
#   sprintf(
#     "exe/062_ising_mmc %g_%g_%d %d %g %g %d %d %d",
#     min_temp, max_temp, num_chains,
#     L, min_temp, max_temp, num_chains,
#     delta_swap, num_steps
#   )
# )

fname <- sprintf("out/062_%g_%g_%d.csv", min_temp, max_temp, num_chains)
eq_data <- fread(fname)[1001:.N][, iter := 1:.N]

swaps <- eq_data |>
  _[, .SD, .SDcols = patterns("swap")] |>
  setnames(c("c1", "c2", "swapped")) |>
  na.omit() |>
  _[, let(c1 = c1 + 1, c2 = c2 + 1)]
# Total swapping rate
message(sum(swaps$swapped) / nrow(swaps))

swaps[, .(rate = sum(swapped) / .N)
      , keyby = .(T1 = temps[pmin(c1, c2)], T2 = temps[pmax(c1, c2)])]

plt_hist <- melt(
  eq_data,
  "iter",
  measure(value.name, chain = as.integer, pattern = "(energy).([0-9]+)")
) |>
  _[, let(energy = energy / L^2, chain = as.factor(temps[chain]))] |>
  ggplot() +
    geom_histogram(
      aes(energy, after_stat(density), fill = chain),
      position = "identity",
      binwidth = 0.011,
      alpha = 0.75
    ) +
    scale_fill_viridis_d() +
    labs(x = "Energy per spin", y = "Density", fill = "Temperature")

plot_tex("062a", plt_hist, asp_ratio = 1.4, scale_factor = 0.9)

# Replicate the simulation without swaps
# system(
#   sprintf(
#     "exe/062_ising_mmc %g_%g_%d_ns %d %g %g %d %d %d",
#     min_temp, max_temp, num_chains,
#     L, min_temp, max_temp, num_chains,
#     num_steps + 2, # delta_swap > num_steps ==> no swaps
#     num_steps
#   )
# )

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

plt_acf <- merge(
  energies,
  energies_ns,
  by = c("iter", "chain"),
  suffixes = c(".mmc", ".single")
) |>
  melt(c("iter", "chain"), measure(value.name, algo, sep = ".")) |>
  _[, .(lag = 1:250, acf = acf_fft(energy, max_lag = 250, thr = NULL))
    , keyby = .(algo, chain)] |>
  ggplot() +
    geom_line(aes(lag, acf, colour = algo), linewidth = 0.3) +
    facet_wrap(
      vars(chain),
      ncol = 2,
      labeller = as_labeller(\(x) paste("<i>T</i> =", temps[as.integer(x)]))
    ) +
    scale_colour_brewer(
      palette = "Dark2",
      labels = c("With swapping", "No swapping"),
    ) +
    labs(x = "Lag", y = "Autocorrelation function", colour = "Algorithm") +
    theme(strip.text = ggtext::element_markdown(), legend.position = "bottom")

plot_tex("062b", plt_acf, asp_ratio = 0.9, scale_factor = 1)
