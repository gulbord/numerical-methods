wd <- unlist(strsplit(getwd(), "/"))
src <- match("src", wd)
if (!is.na(src))
  setwd(paste(wd[1:(src - 1)], collapse = "/"))
source("src/preamble.R")
if (!exists(".Random.seed")) invisible(runif(1))

L <- 50L
N <- L * L
num_steps <- 5e5L
Tc <- 2 / log(1 + sqrt(2))
temps <- c(Tc / 2, Tc, 2 * Tc)
temp_names <- c("low", "crit", "high")

# for (i in seq_along(temps)) {
#   argv <- sprintf(
#     "exe/061_ising_wolff %s %d %g %d 0",
#     temp_names[i], L, temps[i], num_steps
#   )
#   system(argv)
# }

plt_temps <- lapply(
  temp_names,
  function(f) {
    df <- fread(sprintf("out/061_%s.csv", f), select = "clus_size")
    h <- hist(df$clus_size, breaks = "FD", plot = FALSE)

    mask <- h$counts > 0
    x <- h$mids[mask]
    y <- h$counts[mask]
    err <- sqrt(y)

    ggplot(data.table(x, y, err)) +
      geom_pointrange(
        aes(x, y, ymin = y - err, ymax = y + err),
        size = 0.04,
        linewidth = 0.4,
      ) +
      scale_y_log10(guide = "axis_logticks") +
      labs(x = "Cluster size", y = "Count")
  }
)

plot_tex("061a", plt_temps[[1]], asp_ratio = 4 / 3, scale_factor = 0.75)
plot_tex("061b", plt_temps[[2]], asp_ratio = 4 / 3, scale_factor = 0.75)
plot_tex("061c", plt_temps[[3]], asp_ratio = 4 / 3, scale_factor = 0.75)

# Second part: autocorrelations

lat_sides <- round(exp(seq(log(40), log(70), length.out = 6)))
num_steps <- 1e6L

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

plt_acor <- taus |>
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

plot_tex("061d", plt_acor, asp_ratio = 1, scale_factor = 0.75)

# Parameters
fits <- taus |>
  melt(
    id.vars = "side",
    measure.vars = measure(algorithm, variable, sep = ".")
  ) |>
  _[, broom::tidy(lm(log(value) ~ log(side)))
    , by = .(algorithm, variable)]

fwrite(fits, "src/data/061_fits.csv")
