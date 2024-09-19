wd <- unlist(strsplit(getwd(), "/"))
src <- match("src", wd)
if (!is.na(src))
  setwd(paste(wd[1:(src - 1)], collapse = "/"))
source("src/preamble.R")
library(stringr)
if (!exists(".Random.seed")) invisible(runif(1))

num_particles <- 100L
num_steps <- 1e5L
num_realizations <- 10L

densities <- c(0.05, 0.3, 0.5, 1)
max_disps <- c(0.01, 0.1, 0.3, 0.6, 1)
init <- c("random", "lattice")
total <- length(max_disps) * length(densities)
pars <- data.table(
  rho = rep(densities, each = 2L * length(max_disps)),
  dmax = rep(max_disps, times = 2L * length(densities)),
  init = rep(init, times = total)
)[, seed := abs(.Random.seed[sample(seq_along(.Random.seed), .N)])]

split(pars, seq_len(nrow(pars))) |>
  parallel::mclapply(
    function(x) {
      cfg_file <- tempfile()
      cfg_text <- c(
        paste("num_particles", num_particles),
        paste("density", x$rho),
        paste("max_disp", x$dmax),
        paste("temperature 1.0"),
        paste("num_steps", num_steps),
        paste("num_realizations", num_realizations),
        paste("init_conf", x$init),
        paste("seed", x$seed)
      )
      writeLines(text = cfg_text, con = cfg_file, sep = "\n")

      system(
        sprintf(
          "exe/083_hard_spheres %s r%g_d%g",
          cfg_file, x$rho, x$dmax
        )
      )

      unlink(cfg_file)
    },
    mc.cores = min(10L, parallel::detectCores() - 2L)
  )

eq_time <- 1e4L
obs <- lapply(
  fnames,
  function(f) {
    rho <- as.numeric(str_extract(f, "(?<=r)[.0-9]+"))
    dmax <- as.numeric(str_extract(f, "(?<=d)[.0-9]+"))
    init <- sub(".*_([a-z]+).csv", "\\1", f)

    df <- fread(f)[(eq_time + 1):.N]
    df[, let(realization = NULL, energy = energy / (100 * 99))]

    return(cbind(rho = rho, dmax = dmax, init = init, df[, lapply(.SD, mean)]))
  }
) |>
  rbindlist()

plt <- melt(obs, measure.vars = c("acc_ratio", "energy")) |>
  ggplot(aes(dmax, value, colour = factor(rho))) +
    geom_line(linewidth = 0.5) +
    geom_point(size = 1) +
    scale_y_continuous(
      breaks = scales::pretty_breaks(),
      trans = scales::pseudo_log_trans(base = 10),
      guide = "axis_logticks",
    ) +
    scale_colour_viridis_d() +
    facet_grid(
      rows = vars(variable),
      cols = vars(init),
      scales = "free_y",
      labeller = as_labeller(
        c(
          lattice = "Cubic lattice initialization",
          random = "Random initialization",
          acc_ratio = "Acceptance ratio",
          energy = "Energy (number of overlaps)"
        )
      )
    ) +
    labs(
      x = "Maximum displacement",
      y = "Average over 10 realizations",
      colour = "Density",
    ) +
    theme(legend.position = "bottom")

plot_tex("083", plt, asp_ratio = 0.75, scale_factor = 1)
