wd <- unlist(strsplit(getwd(), "/"))
src <- match("src", wd)
if (!is.na(src))
  setwd(paste(wd[1:(src - 1)], collapse = "/"))
source("src/preamble.R")
library(stringr)
if (!exists(".Random.seed")) invisible(runif(1))

launch_sim <- function(x, prefix = "", num_steps = 5e5) {
  if (prefix != "")
    prefix <- paste0(prefix, "_")
  fname <- sprintf("%sL%d_T%g", prefix, x$side, x$temp)
  system(
    sprintf(
      "exe/051_ising_metropolis %s %d %f %d %d",
      fname, x$side, x$temp, num_steps, x$seed
    )
  )
}

Tc <- 2 / log(1 + sqrt(2))
temp_step <- 0.005
num_temps <- 60
temps <- c(
  seq(to = Tc - temp_step, by = temp_step, length.out = num_temps %/% 2),
  seq(from = Tc, by = temp_step, length.out = num_temps - num_temps %/% 2)
)

pars <- data.table(
  side = rep(c(32L, 45L, 64L, 90L), each = num_temps),
  temp = rep(temps, 4),
  seed = .Random.seed[seq_len(4 * num_temps)]
)

# split(pars, seq_len(nrow(pars))) |>
#   parallel::mclapply(
#     \(x) launch_sim(x, num_steps = 1e6L),
#     mc.cores = min(10, parallel::detectCores())
#   )

eq_time <- 10000

fluct <- pars |>
  _[, sprintf("out/051_L%d_T%g.csv", side, temp)] |>
  purrr::map(
    function(fname) {
      side <- as.integer(str_extract(fname, "(?<=L)\\d+"))
      temp <- as.numeric(str_extract(fname, "(?<=T)\\d+\\.?\\d*"))

      df <- fread(fname)[(eq_time + 1):.N]
      df[, let(magnet = abs(magnet) / side^2, energy = energy / side^2)]
      N <- nrow(df)

      results <- lapply(
        names(df),
        function(col) {
          acf <- acf_fft(df[[col]], max_lag = 250, thr = 0.005)[-1]
          tau <- sum((1 - seq_along(acf) / N) * acf)

          return(
            list(
              obs = col,
              tau = tau,
              mean = mean(df[[col]]),
              var = var(df[[col]]) * (N - 1) / (N - 1 - 2 * tau)
            )
          )
        }
      )

      return(cbind(side = side, temp = temp, rbindlist(results)))
    },
    .progress = TRUE
  ) |>
  rbindlist() |>
  _[, var := var * side^2 / temp] |>
  _[obs == "energy", var := var / temp]

# fwrite(fluct, "src/data/051_fluct.csv")
# fluct <- fread("src/data/051_fluct.csv")

plt_fluct <- fluct |>
  ggplot(aes(temp, var)) +
    geom_line(aes(colour = factor(side))) +
    facet_wrap(
      vars(obs),
      nrow = 2,
      scales = "free_y",
      labeller = as_labeller(c(
        energy = "Specific heat per spin",
        magnet = "Magnetic susceptibility per spin"
      ))
    ) +
    scale_colour_viridis_d() +
    scale_x_continuous(
      breaks = c(pretty(fluct$temp), Tc),
      labels = c(pretty(fluct$temp), "<i>T</i><sub>c</sub>"),
    ) +
    scale_y_log10(guide = "axis_logticks") +
    labs(
      x = "Temperature",
      y = "Monte Carlo average",
      colour = "Lattice size",
    ) +
    theme(
      legend.position = "bottom",
      axis.text.x = ggtext::element_markdown(),
    )

plot_tex("051a", plt_fluct, asp_ratio = 0.75, scale_factor = 0.8)

plt_tau <- fluct |>
  ggplot(aes(temp, tau)) +
    geom_line(aes(colour = factor(side))) +
    facet_wrap(
      vars(obs),
      nrow = 2,
      scales = "free_y",
      labeller = as_labeller(c(
        energy = "Energy",
        magnet = "Magnetization"
      ))
    ) +
    scale_colour_viridis_d() +
    scale_x_continuous(
      breaks = c(pretty(fluct$temp), Tc),
      labels = c(pretty(fluct$temp), "<i>T</i><sub>c</sub>"),
    ) +
    scale_y_log10(guide = "axis_logticks") +
    labs(
      x = "Temperature",
      y = "Autocorrelation time",
      colour = "Lattice size",
    ) +
    theme(
      legend.position = "bottom",
      axis.text.x = ggtext::element_markdown(),
    )

plot_tex("051b", plt_tau, asp_ratio = 0.75, scale_factor = 0.8)

# Another set of simulations for a bigger energy/magnetization plot
temps_big <- seq(0.2, 4.2, by = 0.1)
pars_big <- data.table(
  side = rep(unique(pars$side), each = length(temps_big)),
  temp = rep(temps_big, 4),
  seed = .Random.seed[seq_len(4 * length(temps_big))]
)

# split(pars_big, seq_len(nrow(pars_big))) |>
#   parallel::mclapply(
#     \(x) launch_sim(x, num_steps = 1e6L),
#     mc.cores = min(10, parallel::detectCores())
#   )

observ <- pars_big |>
  _[, sprintf("out/051_L%d_T%g.csv", side, temp)] |>
  parallel::mclapply(
    function(fname) {
      side <- as.integer(str_extract(fname, "(?<=L)\\d+"))
      temp <- as.numeric(str_extract(fname, "(?<=T)\\d+\\.?\\d*"))

      df <- fread(fname)[(eq_time + 1):.N]
      df[, let(magnet = abs(magnet) / side^2, energy = energy / side^2)]
      N <- nrow(df)

      results <- lapply(
        names(df),
        function(col) {
          acf <- acf_fft(df[[col]], max_lag = 250, thr = 0.005)[-1]
          tau <- sum((1 - seq_along(acf) / N) * acf)

          return(list(obs = col, tau = tau, mean = mean(df[[col]])))
        }
      )

      return(cbind(side = side, temp = temp, rbindlist(results)))
    },
    mc.cores = min(10, parallel::detectCores())
  ) |>
  rbindlist() |>
  melt(id.vars = c("side", "temp", "obs"))

# fwrite(observ, "src/data/051_observ.csv")
# observ <- fread("src/data/051_observ.csv")

plt_obs <- ggplot(observ[variable == "mean"], aes(temp, value)) +
  geom_point(aes(colour = factor(side)), size = 0.5) +
  facet_wrap(
    vars(obs),
    nrow = 2,
    scales = "free_y",
    labeller = as_labeller(c(
      energy = "Energy per spin",
      magnet = "Magnetization per spin"
    ))
  ) +
  scale_colour_viridis_d() +
  scale_fill_viridis_d() +
  scale_x_continuous(
    breaks = c(pretty(observ$temp), Tc),
    labels = c(pretty(observ$temp), "<i>T</i><sub>c</sub>"),
  ) +
  labs(
    x = "Temperature",
    y = "Monte Carlo average",
    colour = "Lattice size",
    fill = "Lattice size",
  ) +
  theme(
    legend.position = "bottom",
    axis.text.x = ggtext::element_markdown(),
  )

plot_tex("051c", plt_obs, asp_ratio = 0.75, scale_factor = 0.75)
