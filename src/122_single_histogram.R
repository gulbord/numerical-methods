wd <- unlist(strsplit(getwd(), "/"))
src <- match("src", wd)
if (!is.na(src))
  setwd(paste(wd[1:(src - 1)], collapse = "/"))
source("src/preamble.R")
if (!exists(".Random.seed")) invisible(runif(1))

L <- 100
min_temp <- 2.2
max_temp <- 2.3
num_temps <- 11

pars <- data.table(temp = seq(min_temp, max_temp, length.out = num_temps)) |>
  _[, seed := abs(.Random.seed[sample(seq_along(.Random.seed), .N)])]

# split(pars, seq_len(nrow(pars))) |>
#   parallel::mclapply(
#     function(x) {
#       system(
#         sprintf(
#           "exe/051_ising_metropolis shm_T%g %d %f %d %d",
#           x$temp, L, x$temp, 2e6, x$seed
#         )
#       )
#     },
#     mc.cores = min(nrow(pars), getDTthreads())
#   )

# Read data
eq_time <- 1e4
samples <- lapply(
  pars$temp,
  \(t) list(
    temp = t,
    energy = fread(sprintf("out/051_shm_T%g.csv", t))[(eq_time + 1):.N, energy]
  )
)

temp_seq <- seq(min_temp, max_temp, length.out = 100)
which_preds <- seq(1, nrow(pars), 3)
preds <- samples[which_preds] |>
  parallel::mclapply(
    function(x) {
      result <- data.table(temp_in = x$temp, temp_out = temp_seq)
      set(
        result,
        j = "energy",
        value = vapply(
          result$temp_out,
          function(t) {
            boltz <- exp((1 / x$temp - 1 / t) * x$energy)
            return(sum((x$energy / L^2) * boltz) / sum(boltz))
          },
          numeric(1) 
        )
      )
      return(result)
    },
    mc.cores = min(5, getDTthreads())
  ) |>
  rbindlist()

plt_hist <- rbindlist(samples[which_preds]) |>
  _[, energy := energy / L^2] |>
  ggplot(aes(fill = factor(temp))) +
    geom_histogram(
      aes(energy, after_stat(density)),
      bins = 86,
      position = "identity",
      alpha = 0.5,
    ) +
    scale_fill_viridis_d() +
    scale_x_continuous(breaks = scales::pretty_breaks()) +
    scale_y_continuous(breaks = scales::pretty_breaks()) +
    labs(x = "Energy per spin", y = "Density", fill = "Temperature")

plot_tex("122a", plt_hist, asp_ratio = 4 / 3, scale_factor = 0.9)

get_meanrange <- function(x) {
  N <- length(x)
  acf <- acf_fft(x, max_lag = 250, thr = 0.005)[-1]
  tau <- sum((1 - seq_along(acf) / N) * acf)
  return(list(mean = mean(x), sd = sd(x) * sqrt((N - 1) / (N - 1 - 2 * tau))))
}

samples_means <- rbindlist(samples) |>
  _[, get_meanrange(energy / L^2), by = .(temp_in = temp)]

plt_preds <- ggplot(preds) +
  geom_line(
    aes(temp_out, energy, colour = factor(temp_in)),
    linewidth = 0.35
  ) +
  geom_pointrange(
    aes(temp_in, mean, ymin = mean - sd, ymax = mean + sd),
    data = samples_means,
    linewidth = 0.35,
    size = 0.07,
  ) +
  scale_colour_viridis_d() +
  scale_x_continuous(breaks = scales::pretty_breaks()) +
  scale_y_continuous(breaks = scales::pretty_breaks()) +
  labs(
    x = "Temperature",
    y = "Energy per spin",
    colour = "Interpolation temperature",
  ) +
  theme(legend.position = "bottom", legend.title = ggtext::element_markdown())

plot_tex("122b", plt_preds, asp_ratio = 1.1, scale_factor = 0.8)
