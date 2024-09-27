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

# parallel::mclapply(
#   split(pars, seq_len(nrow(pars))),
#   function(x) {
#     cfg_file <- tempfile()
#     cfg_text <- c(
#       paste("box_size", box_size),
#       paste("density", density),
#       paste("temperature", temperature),
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
#     writeLines(text = cfg_text, con = cfg_file, sep = "\n")
# 
#     system(sprintf("exe/102_lennard_jones %s rc%g", cfg_file, x$r_cut))
# 
#     unlink(cfg_file)
#   },
#   mc.cores = min(10L, parallel::detectCores() - 2L)
# )

pot <- sprintf("out/102_rc%g_obs.csv", pars$r_cut) |>
  lapply(
    function(fname) {
      r_cut <- as.numeric(sub(".*rc(\\d+\\.?\\d*)_.*", "\\1", fname))
      return(cbind(r_cut, fread(fname)))
    }
  ) |>
  rbindlist()

plt_pot <- ggplot(pot[sample > 10], aes(pot_energy, factor(r_cut))) +
  ggridges::geom_density_ridges(
    stat = "binline",
    binwidth = \(x) 2 * IQR(x) / length(x)^(1 / 3),
    draw_baseline = FALSE,
    scale = 0.9,
    linewidth = 0.25
  ) +
  scale_y_discrete(labels = c("2<sup>1/6</sup>", unique(pot$r_cut)[-1])) +
  labs(x = "Potential energy", y = "Cutoff radius") +
  theme(axis.text.y = ggtext::element_markdown())

plot_tex("102a", plt_pot, asp_ratio = 4 / 5, scale_factor = 1)

rdf <- sprintf("out/102_rc%g_rdf.csv", pars$r_cut) |>
  lapply(
    function(fname) {
      r_cut <- as.numeric(sub(".*rc(\\d+\\.?\\d*)_.*", "\\1", fname))
      return(cbind(r_cut, fread(fname)[, .(rdf = mean(rdf)), by = radius]))
    }
  ) |>
  rbindlist()

plt_rdf_all <- ggplot(rdf, aes(radius, rdf, colour = r_cut, group = r_cut)) +
  geom_line(linewidth = 0.25) +
  scale_colour_viridis_c(breaks = scales::pretty_breaks()) +
  labs(
    x = "<i>r</i>",
    y = "<i>g</i>(<i>r</i>)",
    colour = "Cutoff radius",
  ) +
  theme(axis.title = ggtext::element_markdown())

plot_tex("102b", plt_rdf_all, asp_ratio = 4 / 3, scale_factor = 0.9)

plt_rdf_some <- rdf[r_cut %in% c(r_cut[1], 1.5, 2.5, 3.5)] |>
  ggplot(aes(radius, rdf)) +
    geom_line(linewidth = 0.3) +
    facet_wrap(
      vars(r_cut),
      labeller = labeller(
        r_cut = function(x) {
          paste(
            "<i>r</i><sub>cut</sub> =",
            ifelse(x < 1.5, "2<sup>1/6</sup>", x)
          )
        }
      )
    ) +
    labs(x = "<i>r</i>", y = "<i>g</i>(<i>r</i>)") +
    theme(
      strip.text = ggtext::element_markdown(),
      axis.title = ggtext::element_markdown(),
    )

plot_tex("102c", plt_rdf_some, asp_ratio = 1.1, scale_factor = 1)
