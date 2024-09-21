wd <- unlist(strsplit(getwd(), "/"))
src <- match("src", wd)
if (!is.na(src))
  setwd(paste(wd[1:(src - 1)], collapse = "/"))
source("src/preamble.R")
library(stringr)
if (!exists(".Random.seed")) invisible(runif(1))

num_particles <- 100L
max_disp <- 0.3
num_steps <- 1e5L
num_realizations <- 10L

num_rho <- 11L
pars <- data.table(
  rho = rep(seq(0.05, 0.9, length.out = num_rho), each = 2L),
  temp = rep(c(0.9, 2), times = num_rho),
  seed = abs(.Random.seed[sample(seq_along(.Random.seed), 2L * num_rho)])
)

# split(pars, seq_len(nrow(pars))) |>
#   parallel::mclapply(
#     function(x) {
#       cfg_file <- tempfile()
#       cfg_text <- c(
#         paste("num_particles", num_particles),
#         paste("density", x$rho),
#         paste("max_disp", max_disp),
#         paste("temperature", x$temp),
#         paste("num_steps", num_steps),
#         paste("num_realizations", num_realizations),
#         paste("init_conf lattice"),
#         paste("seed", x$seed)
#       )
#       writeLines(text = cfg_text, con = cfg_file, sep = "\n")
# 
#       system(
#         sprintf(
#           "exe/084_lennard_jones %s T%.1f_r%g",
#           cfg_file, x$temp, x$rho
#         )
#       )
# 
#       unlink(cfg_file)
#     },
#     mc.cores = min(5L, parallel::detectCores() - 2L)
#   )

eq_steps <- 1e4L

obs <- pars[, sprintf("out/084_T%.1f_r%g.csv", temp, rho)] |>
  purrr::map(
    function(fname) {
      rho <- as.numeric(str_extract(fname, "(?<=r)\\d+\\.?\\d*"))
      temp <- as.numeric(str_extract(fname, "(?<=T)\\d+\\.?\\d*"))

      df <- fread(fname)[(eq_steps + 1L):.N]
      df[, let(realization = NULL, energy = energy / num_particles)]
      
      return(
        cbind(
          density = rho,
          temp = temp,
          mean = df[, lapply(.SD, mean)],
          sd = df[, lapply(.SD, sd)]
        )
      )
    },
    .progress = TRUE
  ) |>
  rbindlist() |>
  melt(measure.vars = measure(value.name, variable, sep = ".")) 

# Theorical result
theo <- merge(
  fread("src/data/lj_t09.csv")[, temp := 0.9],
  fread("src/data/lj_t2.csv")[, temp := 2],
  by = c("density", "temp"),
  all = TRUE
)[, .(density, temp, pressure = fcoalesce(.SD))
  , .SDcols = patterns("^pressure")]

plt <- ggplot(obs[variable == "pressure"], aes(colour = factor(temp))) +
  geom_line(
    aes(density, pressure),
    data = theo,
    linetype = "dashed",
    linewidth = 0.4,
  ) +
  geom_pointrange(
    aes(density, mean, ymin = mean - sd, ymax = mean + sd),
    size = 0.1,
    linewidth = 0.4
  ) +
  scale_x_continuous(breaks = scales::pretty_breaks()) +
  scale_y_continuous(breaks = scales::pretty_breaks()) +
  scale_colour_brewer(palette = "Dark2") +
  labs(x = "Density", y = "Pressure", colour = "Temperature")

plot_tex("084", plt, asp_ratio = 3 / 2, scale_factor = 0.75)
