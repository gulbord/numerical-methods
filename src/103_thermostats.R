wd <- unlist(strsplit(getwd(), "/"))
src <- match("src", wd)
if (!is.na(src))
  setwd(paste(wd[1:(src - 1)], collapse = "/"))
source("src/preamble.R")
if (!exists(".Random.seed")) invisible(runif(1))

pars <- data.table(num_particles = rep(seq(20, 200, by = 20), 2)) |>
  _[, thermostat := rep(c("andersen", "berendsen"), each = .N / 2)] |>
  _[, seed := abs(.Random.seed[sample(seq_along(.Random.seed), .N)])]

box_size <- 10
temperature <- 2
rdf_max_radius <- 5
rdf_num_bins <- 200L
max_disp <- 0.3
step_size <- 0.01
num_steps <- 10000L
num_eq_steps <- 1000L
thinning <- 10L
num_realizations <- 10L
init_conf <- "lattice"
eq_type <- "mc"
andersen_freq <- 10
berendsen_tau <- 0.1

# parallel::mclapply(
#   split(pars, seq_len(nrow(pars))),
#   function(x) {
#     cfg_file <- tempfile()
#     cfg_text <- c(
#       paste("box_size", box_size),
#       paste("num_particles", x$num_particles),
#       paste("temperature", temperature),
#       paste("thermostat", x$thermostat),
#       paste("andersen_freq", andersen_freq),
#       paste("berendsen_tau", berendsen_tau),
#       paste("rdf_max_radius", rdf_max_radius),
#       paste("rdf_num_bins", rdf_num_bins),
#       paste("r_cut", x$r_cut),
#       paste("max_disp", max_disp),
#       paste("step_size", step_size),
#       paste("num_steps", num_steps),
#       paste("num_eq_steps", num_eq_steps),
#       paste("thinning", thinning),
#       paste("num_realizations", num_realizations),
#       paste("init_conf", init_conf),
#       paste("eq_type", eq_type),
#       paste("seed", x$seed)
#     )
# 
#     writeLines(text = cfg_text, con = cfg_file, sep = "\n")
# 
#     system(
#       sprintf(
#         "exe/102_lennard_jones %s N%d_%s",
#         cfg_file, x$num_particles, substr(x$thermostat, 1, 3)
#       )
#     )
# 
#     unlink(cfg_file)
#   },
#   mc.cores = min(10, parallel::detectCores() - 2)
# )
#
# # Clean up RDF files
# lapply(
#   sprintf(
#     "out/102_N%d_%s_rdf.csv",
#     pars$num_particles,
#     substr(pars$thermostat, 1, 3)
#   ),
#   \(f) system(paste("rm", f))
# )

obs <- sprintf(
  "out/102_N%d_%s_obs.csv",
  pars$num_particles,
  substr(pars$thermostat, 1, 3)
) |>
  lapply(
    function(fname) {
      N <- as.integer(sub(".*N(\\d+)_.*", "\\1", fname))
      therm <- sub(".*_(.*)_obs.*", "\\1", fname)
      return(cbind(N, therm, fread(fname)))
    }
  ) |>
  rbindlist()

plt_kin <- ggplot(obs, aes(factor(N), kin_energy)) +
  geom_boxplot(outlier.size = 0.01, linewidth = 0.3) +
  facet_wrap(
    vars(therm),
    ncol = 2,
    scales = "free",
    labeller = as_labeller(c(and = "Andersen", ber = "Berendsen")),
  ) +
  scale_y_continuous(breaks = scales::pretty_breaks()) +
  labs(x = "Number of particles", y = "Kinetic energy per particle")

plot_tex("103a", plt_kin, asp_ratio = 1.25, scale_factor = 1)

get_fluct <- function(x) {
  N <- length(x)
  acf <- acf_fft(x, max_lag = 250, thr = 0.005)[-1]
  tau <- sum((1 - seq_along(acf) / N) * acf)
  return(var(x) * (N - 1) / ((N - 1 - 2 * tau) * mean(x)^2))
}

plt_fluct <- obs[, .(fluct = get_fluct(temperature))
                 , by = .(N, therm, realization)] |>
  _[, .(mean = mean(fluct), err = sd(fluct) / sqrt(.N)), by = .(N, therm)] |>
  ggplot(aes(N, mean)) +
    geom_function(
      fun = \(x) 2 / (3 * x),
      linetype = "dashed",
      linewidth = 0.25,
    ) +
    geom_pointrange(
      aes(ymin = mean - err, ymax = mean + err, colour = therm),
      size = 0.05,
      linewidth = 0.3,
    ) +
    scale_colour_brewer(
      palette = "Dark2",
      labels = c(and = "Andersen", ber = "Berendsen"),
    ) +
    scale_x_continuous(breaks = scales::pretty_breaks()) +
    labs(
      x = "Number of particles",
      y = "Relative variance of <i>T<sub>K</sub></i>",
      colour = "Thermostat",
    ) +
    theme(axis.title.y = ggtext::element_markdown())

plot_tex("103b", plt_fluct, asp_ratio = 4 / 3, scale_factor = 0.8)
