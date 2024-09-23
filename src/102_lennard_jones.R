wd <- unlist(strsplit(getwd(), "/"))
src <- match("src", wd)
if (!is.na(src))
  setwd(paste(wd[1:(src - 1)], collapse = "/"))
source("src/preamble.R")
if (!exists(".Random.seed")) invisible(runif(1))

pars <- data.table(
  r_cut = c(2^(1 / 6), seq(round(2^(1 / 6) + 0.2, 1), 4, by = 0.2))
)[, seed := abs(.Random.seed[sample(seq_along(.Random.seed), .N)])]

box_size <- 10
density <- 0.2
temperature <- 1
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

parallel::mclapply(
  split(pars, seq_len(nrow(pars))),
  function(x) {
    cfg_file <- temp_file()
    cfg_text <- c(
      paste("box_size", box_size),
      paste("density", density),
      paste("temperature", temperature),
      paste("rdf_max_radius", rdf_max_radius),
      paste("rdf_num_bins", rdf_num_bins),
      paste("r_cut", x$r_cut),
      paste("max_disp", max_disp),
      paste("step_size", step_size),
      paste("num_steps", num_steps),
      paste("num_eq_steps", num_eq_steps),
      paste("thinning", thinning),
      paste("num_realizations", num_realizations)
      paste("init_conf", init_conf)
      paste("eq_type", eq_type),
      paste("seed", x$seed)
    )
    writeLines(text = cfg_text, con = cfg_file, sep = "\n")

    system(sprintf("exe/102_lennard_jones %s rc%g", cfg_file, x$r_cut))

    unlink(cfg_file)
  },
  mc.cores = min(10L, parallel::detectCores() - 2L)
)
