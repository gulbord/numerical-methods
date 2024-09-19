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

split(pars, seq_len(nrow(pars))) |>
  parallel::mclapply(
    function(x) {
      cfg_file <- tempfile()
      cfg_text <- c(
        paste("num_particles", num_particles),
        paste("density", x$rho),
        paste("max_disp", max_disp),
        paste("temperature", x$temp),
        paste("num_steps", num_steps),
        paste("num_realizations", num_realizations),
        paste("init_conf lattice"),
        paste("seed", x$seed)
      )
      writeLines(text = cfg_text, con = cfg_file, sep = "\n")

      system(
        sprintf(
          "exe/084_lennard_jones %s T%.1f_r%g",
          cfg_file, x$temp, x$rho
        )
      )

      unlink(cfg_file)
    },
    mc.cores = min(5L, parallel::detectCores() - 2L)
  )
