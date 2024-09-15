wd <- unlist(strsplit(getwd(), "/"))
src <- match("src", wd)
if (!is.na(src))
  setwd(paste(wd[1:(src - 1)], collapse = "/"))
source("src/preamble.R")
library(stringr)

Tc <- 2 / log(1 + sqrt(2))
temp_step <- 0.005
num_temps <- 60
temps <- c(
  seq(to = Tc - temp_step, by = temp_step, length.out = num_temps %/% 2),
  seq(from = Tc, by = temp_step, length.out = num_temps - num_temps %/% 2)
)
sides <- c(32, 45, 64, 90)
num_steps <- 6e5

# for (i in seq_along(sides)) {
#   for (j in seq_along(temps)) {
#     message(sprintf(
#         "Processing L = %d, T = %g [%d/%d]",
#         sides[i], temps[j],
#         length(temps) * (i - 1) + j,
#         length(temps) * length(sides)
#     ))
#     fname <- sprintf("L%d_T%g", sides[i], temps[j])
#     system(
#       sprintf(
#         "exe/051_ising_metropolis %s %d %f %d",
#         fname, sides[i], temps[j], num_steps
#       )
#     )
#   }
# }

plot_one <- function(side, temp) {
  fread(sprintf("out/051_L%d_T%g.csv", side, temp)) |>
    _[1:5e4] |>
    _[, names(.SD) := lapply(.SD, \(x) x / side^2)] |>
    _[, iter := 1:.N] |>
    melt(id.vars = "iter") |>
    ggplot(aes(iter, value)) +
      geom_line() +
      facet_wrap(vars(variable), nrow = 2, scales = "free_y")
}

eq_time <- 5000

fnames <- expand.grid(sides, temps) |>
  apply(1, \(x) sprintf("out/051_L%d_T%g.csv", x[1], x[2]))

# observ <- purrr::map(
#   fnames,
#   function(fname) {
#     side <- as.integer(str_extract(fname, "(?<=L)\\d+"))
#     temp <- as.numeric(str_extract(fname, "(?<=T)\\d+\\.?\\d+"))
# 
#     df <- fread(fname)[(eq_time + 1):.N]
#     df[, let(magnet = abs(magnet) / side^2, energy = energy / side^2)]
#     N <- nrow(df)
# 
#     results <- lapply(
#       names(df),
#       function(col) {
#         acf <- acf_fft(df[[col]], max_lag = 250, thr = 0.005)
#         tau <- sum((1 - seq_along(acf) / N) * acf)
#         uncor <- df[[col]][seq(1, N, by = round(tau))]
# 
#         # Bootstrapped variance
#         bt_var <- boot::boot(
#           uncor,
#           \(x, i) var(x[i]),
#           R = 1000,
#           parallel = "multicore",
#           ncpus = getDTthreads()
#         )
# 
#         var_ci <- boot::boot.ci(
#           bt_var,
#           conf = c(0.8, 0.95),
#           type = "basic"
#         )$basic[, 4:5]
# 
#         return(
#           list(
#             obs = col,
#             mean = mean(uncor),
#             var = bt_var$t0,
#             var_ci80_low = var_ci[1, 1],
#             var_ci80_high = var_ci[1, 2],
#             var_ci95_low = var_ci[2, 1],
#             var_ci95_high = var_ci[2, 2],
#             tau = tau
#           )
#         )
#       }
#     )
# 
#     return(cbind(side = side, temp = temp, rbindlist(results)))
#   },
#   .progress = TRUE
# ) |>
#   rbindlist()

observ <- fread("src/051_results.csv") |>
  melt(
    measure.vars = measure(
      level = as.integer, value.name, pattern = "var_ci(.*)_(.*)"
    )
  ) |>
  _[level == 95] |>
  _[, names(.SD) := lapply(.SD, \(x) x * side^2 / temp),
    .SDcols = c("var", "low", "high")] |>
  _[obs == "energy", names(.SD) := lapply(.SD, \(x) x / temp),
    .SDcols = c("var", "low", "high")] 
plt <- observ |>
  ggplot(aes(temp, var)) +
    geom_pointrange(
      aes(ymin = low, ymax = high, colour = factor(side)),
      size = 0.004,
      linewidth = 0.2,
    ) +
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
      breaks = c(pretty(observ$temp), Tc),
      labels = c(pretty(observ$temp), "<i>T</i><sub>c</sub>"),
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

plot_tex("051a", plt, asp_ratio = 0.75, scale_factor = 0.75)

# Another set of simulations for a bigger energy/magnetization plot
temps_new <- seq(0.2, 4.2, by = 0.1)
{
  sidetemp_new <- list()
  k <- 1
  for (s in sides) {
    for (t in temps_new) {
      sidetemp_new[[k]] <- list(side = s, temp = t)
      k <- k + 1
    }
  }
}

launch_sim <- function(x) {
  fname <- sprintf("L%d_T%g", x$side, x$temp)
  system(
    sprintf(
      "exe/051_ising_metropolis %s %d %f %d",
      fname, x$side, x$temp, num_steps
    )
  )
}

# parallel::mclapply(sidetemp_new, launch_sim, mc.cores = getDTthreads())

fnames_new <- lapply(
  sidetemp_new,
  \(x) sprintf("out/051_L%d_T%g.csv", x$side, x$temp)
)

observ <- purrr::map(
  fnames_new,
  function(fname) {
    side <- as.integer(str_extract(fname, "(?<=L)\\d+"))
    temp <- as.numeric(str_extract(fname, "(?<=T)\\d+\\.?\\d*"))

    df <- fread(fname)[(eq_time + 1):.N]
    df[, let(magnet = abs(magnet) / side^2, energy = energy / side^2)]
    N <- nrow(df)

    results <- lapply(
      names(df),
      function(col) {
        acf <- acf_fft(df[[col]], max_lag = 250, thr = 0.005)
        tau <- if (is.na(acf[1])) 1 else sum((1 - seq_along(acf) / N) * acf)
        uncor <- df[[col]][seq(1, N, by = round(tau))]

        return(
          list(
            obs = col,
            mean = mean(uncor),
            low = quantile(uncor, 0.025),
            high = quantile(uncor, 0.975)
          )
        )
      }
    )

    return(cbind(side = side, temp = temp, rbindlist(results)))
  },
  .progress = TRUE
) |>
  rbindlist()

ggplot(observ, aes(temp, mean)) +
  geom_pointrange(
    aes(ymin = low, ymax = high, colour = factor(side)),
    size = 0.004,
    linewidth = 0.2,
  ) +
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
  scale_x_continuous(
    breaks = c(pretty(observ$temp), Tc),
    labels = c(pretty(observ$temp), "<i>T</i><sub>c</sub>"),
  ) +
  labs(
    x = "Temperature",
    y = "Monte Carlo average",
    colour = "Lattice size",
  ) +
  theme(
    legend.position = "bottom",
    axis.text.x = ggtext::element_markdown(),
  )
