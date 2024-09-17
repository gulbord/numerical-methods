wd <- unlist(strsplit(getwd(), "/"))
src <- match("src", wd)
if (!is.na(src))
  setwd(paste(wd[1:(src - 1)], collapse = "/"))
source("src/preamble.R")
library(stringr)

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
sides <- c(32, 45, 64, 90)

spec_heat <- fread("src/data/051_fluct.csv") |>
  _[obs == "energy", .(side, temp, value = var * (side / temp)^2)]

ggplot(spec_heat, aes(temp, value, colour = factor(side))) +
  geom_point() +
  scale_colour_viridis_d() +
  scale_x_continuous(
    breaks = c(pretty(spec_heat$temp), Tc),
    labels = c(pretty(spec_heat$temp), "<i>T</i><sub>c</sub>"),
  ) +
  labs(
    x = "Temperature",
    y = "Specific heat per spin",
    colour = "Lattice size",
  ) +
  theme(axis.text.x = ggtext::element_markdown())

# Zoom in on the peaks and perform another set of simulations
pars <- data.table(
  side = c(90L, 64L, 45L, 32L),
  low = c(2.26, 2.26, 2.27, 2.27),
  high = c(2.29, 2.30, 2.31, 2.32)
) |>
  _[, .(temp = seq(low, high, length.out = 10)), keyby = side] |>
  _[, seed := abs(sample(.Random.seed, .N))]

# split(pars, seq_len(nrow(pars))) |>
#   parallel::mclapply(
#     \(x) launch_sim(x, prefix = "fss", num_steps = 5e6),
#     mc.cores = min(10, parallel::detectCores())
#   )

eq_steps <- 10000

# fss_spec_heat <- pars |>
#   _[, sprintf("out/051_fss_L%d_T%g.csv", side, temp)] |>
#   parallel::mclapply(
#     function(fname) {
#       side <- as.integer(str_extract(fname, "(?<=L)\\d+"))
#       temp <- as.numeric(str_extract(fname, "(?<=T)\\d+\\.?\\d*"))
# 
#       energy <- fread(fname)[(eq_steps + 1):.N, energy / side^2]
#       N <- length(energy)
# 
#       acf <- acf_fft(energy, max_lag = 250, thr = 0.005)
#       tau <- sum((1 - seq_along(acf) / N) * acf)
# 
#       result <- var(energy) * (side / temp)^2 * (N - 1) / (N - 1 - 2 * tau)
# 
#       return(list(side = side, temp = temp, spec_heat = result))
#     },
#     mc.cores = getDTthreads()
#   ) |>
#   rbindlist()

fss_spec_heat <- fread("src/data/052_fss_spec_heat.csv")

tcrits <- split(fss_spec_heat, by = "side") |>
  lapply(
    function(x) {
      fit <- lm(spec_heat ~ poly(temp, 2), x)
      opt <- optimize(
        \(t) predict(fit, list(temp = t)),
        interval = c(min(x$temp), max(x$temp)),
        maximum = TRUE
      )
      names(opt) <- c("temp", "spec_heat")
      return(opt)
    }
  ) |>
  rbindlist(idcol = "side") |>
  _[, side := as.integer(side)]

plt_tcrit <- ggplot(
  fss_spec_heat,
  aes(temp, spec_heat, group = factor(side))
) +
  geom_point(aes(colour = factor(side)), size = 0.75) +
  geom_smooth(
    aes(colour = factor(side), fill = factor(side)),
    method = "lm",
    formula = y ~ poly(x, 2),
    alpha = 0.25,
    linewidth = 0.5
  ) +
  geom_point(
    data = tcrits,
    shape = 23,
    size = 1,
  ) +
  geom_text(
    aes(label = sprintf("%.3f", temp)),
    data = tcrits,
    nudge_y = -0.03,
    family = "TeX Gyre Pagella",
    size = 7 / .pt
  ) +
  scale_colour_viridis_d() +
  scale_fill_viridis_d() +
  labs(
    x = "Temperature",
    y = "Specific heat per spin",
    colour = "Lattice size",
    fill = "Lattice size",
  )

plot_tex("052a", plt_tcrit, asp_ratio = 5 / 3, scale_factor = 0.9)

# Estimation of nu

plt_nu <- ggplot(tcrits, aes(abs(temp - Tc) / Tc, side)) +
  geom_smooth(
    colour = "black",
    method = "lm",
    formula = y ~ x,
    linewidth = 0.5,
  ) +
  geom_point() +
  scale_x_log10(breaks = scales::pretty_breaks()) +
  scale_y_log10(breaks = scales::pretty_breaks()) +
  labs(
    x = "Relative distance from <i>T</i><sub>c</sub>",
    y = "Lattice size",
  ) +
  theme(axis.title.x = ggtext::element_markdown())

plot_tex("052b", plt_nu, asp_ratio = 4 / 3, scale_factor = 0.75)

nu_fit <- copy(tcrits) |>
  _[, temp := abs(temp - Tc) / Tc] |>
  lm(log(side) ~ log(temp), data = _) |>
  summary() |>
  _[["coefficients"]]
print(sprintf("nu = %g +/- %g", -nu_fit[2, 1], nu_fit[2, 2]))

# Estimation of beta, gamma and alpha

# cbind(tcrits, seed = abs(sample(.Random.seed, 4))) |>
#   split(seq_len(nrow(tcrits))) |>
#   parallel::mclapply(
#     \(x) launch_sim(x, prefix = "crit", num_steps = 5e6),
#     mc.cores = min(10, parallel::detectCores())
#   )

crit_obs <- tcrits[, sprintf("out/051_crit_L%d_T%g.csv", side, temp)] |>
  parallel::mclapply(
    function(fname) {
      side <- as.integer(str_extract(fname, "(?<=L)\\d+"))
      temp <- as.numeric(str_extract(fname, "(?<=T)\\d+\\.?\\d*"))

      df <- fread(fname) |>
        _[(eq_steps + 1):.N] |>
        _[, let(magnet = abs(magnet) / side^2, energy = energy / side^2)]

      acf_e <- acf_fft(df$energy, max_lag = 250, thr = 0.005)
      tau_e <- sum((1 - seq_along(acf_e) / nrow(df)) * acf_e)
      acf_m <- acf_fft(df$magnet, max_lag = 250, thr = 0.005)
      tau_m <- sum((1 - seq_along(acf_m) / nrow(df)) * acf_m)

      N <- nrow(df)
      V <- side^2
      magnet <- mean(df$magnet)
      suscep <- var(df$magnet) * (V / temp) * (N - 1) / (N - 1 - 2 * tau_m)
      spec_heat <- var(df$energy) * (V / temp^2) * (N - 1) / (N - 1 - 2 * tau_e)

      return(
        list(
          side = side,
          temp = temp,
          magnet = magnet,
          suscep = suscep,
          spec_heat = spec_heat
        )
      )
    },
    mc.cores = getDTthreads()
  ) |>
  rbindlist()

crit_fits <- crit_obs |>
  melt(id.vars = c("side", "temp")) |>
  split(by = "variable") |>
  lapply(\(x) summary(lm(log(value) ~ log(side), x))$coefficients)

crit_fits |>
  lapply(
    function(x) {
      # Monte Carlo sampling to determine confidence intervals
      num_samples <- 1e6L
      exp_nu_sim <- rnorm(num_samples, mean = abs(x[2, 1]), sd = x[2, 2])
      nu_sim <- rnorm(num_samples, mean = -nu_fit[2, 1], sd = nu_fit[2, 2])

      exp_sim <- exp_nu_sim / nu_sim

      return(
        c(
          mean = mean(exp_sim),
          sd = sd(exp_sim),
          quantile(exp_sim, c(0.025, 0.975), type = 6)
        )
      )
    }
  )

plt_crit_obs <- crit_obs |>
  melt(id.vars = c("side", "temp")) |>
  ggplot(aes(side, value)) +
    geom_smooth(
      colour = "black",
      method = "lm",
      formula = y ~ x,
      linewidth = 0.5,
    ) +
    geom_point() +
    scale_x_log10(breaks = scales::pretty_breaks()) +
    scale_y_log10(breaks = scales::pretty_breaks()) +
    facet_wrap(
      vars(variable),
      scales = "free_y",
      ncol = 1,
      labeller = as_labeller(
        c(
          magnet = "Magnetization per spin",
          suscep = "Magnetic susceptibility per spin",
          spec_heat = "Specific heat per spin"
        )
      )
    ) +
    labs(x = "Lattice size", y = "Monte Carlo average")

plot_tex("052c", plt_crit_obs, asp_ratio = 2 / 3, scale_factor = 0.9)
