wd <- unlist(strsplit(getwd(), "/"))
src <- match("src", wd)
if (!is.na(src))
  setwd(paste(wd[1:(src - 1)], collapse = "/"))
source("src/preamble.R")
if (!exists(".Random.seed")) invisible(runif(1))

lat_sides <- round(exp(seq(log(40), log(70), length.out = 6)))
num_steps <- 1e6L
Tc <- 2 / log(1 + sqrt(2))

pars <- data.table(
  algo = rep(c("metro", "wolff"), times = length(lat_sides)),
  side = rep(lat_sides, each = 2),
  seed = sample(.Random.seed, 2 * length(lat_sides))
)

# split(pars, seq_len(nrow(pars))) |>
#   parallel::mclapply(
#     function(x) {
#       system(
#         sprintf(
#           "exe/0%s %s%d %d %f %d %d",
#           if (x$algo == "metro") "51_ising_metropolis" else "61_ising_wolff",
#           "acor_L", x$side, x$side, Tc, num_steps, x$seed
#         )
#       )
#     },
#     mc.cores = min(12, parallel::detectCores() - 1)
#   )

get_tau <- function(L, eq_steps) {
  metro <- fread(paste0("out/051_acor_L", L, ".csv"))[eq_steps:.N]
  metro[, magnet := abs(magnet)]

  wolff <- fread(paste0("out/061_acor_L", L, ".csv"))[eq_steps:.N]
  avg_cs <- mean(wolff$clus_size)
  wolff[, let(clus_size = NULL, magnet = abs(magnet))]
  N <- nrow(metro)

  res <- lapply(
    cbind(metro = metro, wolff = wolff),
    \(x) sum(acf_fft(x, max_lag = 250, thr = 0.005)[-1])
  )

  res$wolff.energy <- res$wolff.energy * avg_cs / L^2
  res$wolff.magnet <- res$wolff.magnet * avg_cs / L^2

  return(res)
}

taus <- parallel::mclapply(
  lat_sides,
  \(L) get_tau(L, eq_steps = 10000L),
  mc.cores = min(length(lat_sides), parallel::detectCores() - 1)
) |>
  rbindlist() |>
  _[, side := lat_sides]

plt <- taus |>
  melt(
    id.vars = "side",
    measure.vars = measure(algorithm, variable, sep = ".")
  ) |>
  _[, variable := factor(
    variable,
    levels = c("energy", "magnet"),
    labels = c("Energy", "Magnetization")
  )] |>
  ggplot(aes(side, value, colour = variable, fill = variable)) +
    geom_point(size = 1) +
    scale_x_log10(guide = "axis_logticks") +
    scale_y_log10(guide = "axis_logticks") +
    scale_colour_brewer(palette = "Dark2") +
    scale_fill_brewer(palette = "Dark2") +
    geom_smooth(method = "lm", formula = y ~ x, linewidth = 0.5) +
    facet_wrap(
      vars(algorithm),
      nrow = 2,
      scale = "free_y",
      labeller = as_labeller(c(metro = "Metropolis", wolff = "Wolff")),
    ) +
    labs(
      x = "Lattice size",
      y = "Autocorrelation time",
      colour = "Observable",
      fill = "Observable",
    )

plot_tex("061d", plt, asp_ratio = 1, scale_factor = 0.75)

# Parameters
fits <- taus |>
  melt(
    id.vars = "side",
    measure.vars = measure(algorithm, variable, sep = ".")
  ) |>
  _[, broom::tidy(lm(log(value) ~ log(side)))
    , by = .(algorithm, variable)]

fwrite(fits, "src/data/061b_fits.csv")
