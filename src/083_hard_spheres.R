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

densities <- c(0.05, 0.3, 0.5, 0.7, 1)
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
          "exe/083_hard_spheres %s r%g_d%g_%s",
          cfg_file, x$rho, x$dmax, x$init
        )
      )

      unlink(cfg_file)
    },
    mc.cores = min(10L, parallel::detectCores() - 2L)
  )

eq_steps <- 1e4L

obs <- pars[, sprintf("out/083_r%g_d%g_%s.csv", rho, dmax, init)] |>
  purrr::map(
    function(fname) {
      rho <- as.numeric(str_extract(fname, "(?<=r)\\d+\\.?\\d*"))
      dmax <- as.numeric(str_extract(fname, "(?<=d)\\d+\\.?\\d*"))
      temp <- as.numeric(str_extract(fname, "(?<=T)\\d+\\.?\\d*"))
      init <- sub(".*_([a-z]+).csv", "\\1", fname)

      df <- fread(fname)[(eq_steps + 1):.N]
      df[, let(realization = NULL, energy = energy / 1e6)]

      return(
        cbind(rho = rho, dmax = dmax, init = init, df[, lapply(.SD, mean)])
      )
    },
    .progress = TRUE
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

plot_tex("083", plt, asp_ratio = 1, scale_factor = 1)
