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
num_reps <- 10
pars <- data.table(
  side = c(90L, 64L, 45L, 32L),
  low = c(2.26, 2.26, 2.27, 2.27),
  high = c(2.29, 2.29, 2.31, 2.32)
) |>
  _[, .(temp = seq(low, high, length.out = 10)), keyby = side] |>
  _[rep(seq_len(.N), each = num_reps)] |>
  _[, rep := 1:.N, by = .(side, temp)]

split(pars, seq_len(nrow(pars))) |>
  parallel::mclapply(
    \(x) launch_sim(x[, !"rep"], prefix = paste0("fss", x$rep)),
    mc.cores = min(10, parallel::detectCores())
  )

fnames <- split(pars, seq_len(nrow(pars))) |>
  lapply(\(x) sprintf("out/051_fss%d_L%d_T%g.csv", x$rep, x$side, x$temp)) |>
  unlist(use.names = FALSE)

eq_steps <- 5000
rowSds <- function(x, ...) {
  sqrt(rowSums((x - rowMeans(x, ...))^2, ...) / (dim(x)[2] - 1))
}


fss_spec_heat <- pars[, sprintf("out/051_fss%d_L%d_T%g.csv", rep, side, temp) |>
         lapply(\(x) fread(x)[(eq_steps + 1):.N, energy / side^2]) |>
         lapply(
           function(x) {
             N <- length(x)
             acf <- acf_fft(x, max_lag = 250, thr = 0.005)
             tau <- sum((1 - seq_along(acf) / N) * acf)
             return(var(x[seq(1, N, by = round(tau))]) * (side / temp)^2)
           }
         )
     , by = .(side, temp)] |>
  _[, .(side, temp, mean = rowMeans(.SD), sd = rowSds(.SD))
    , .SDcols = !c("side", "temp")]

ggplot(fss_spec_heat, aes(temp, mean, colour = factor(side))) +
  geom_pointrange(aes(ymin = mean - sd, ymax = mean + sd))
