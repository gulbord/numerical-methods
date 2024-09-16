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
      "exe/051_ising_metropolis %s %d %f %d",
      fname, x$side, x$temp, num_steps
    )
  )
}

Tc <- 2 / log(1 + sqrt(2))
sides <- c(32, 45, 64, 90)

spec_heat <- fread("src/data/051_results.csv") |>
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
)[, .(temp = seq(low, high, length.out = 10)), keyby = side]

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
# 
#       acf <- acf_fft(energy, max_lag = 250, thr = 0.005)
#       tau <- sum((1 - seq_along(acf) / length(energy)) * acf)
# 
#       result <- var(energy) * (1 + 2 * tau) * (side / temp)^2
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
  rbindlist(idcol = "side")

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
    nudge_y = -12,
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
