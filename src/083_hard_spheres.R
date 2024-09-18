wd <- unlist(strsplit(getwd(), "/"))
src <- match("src", wd)
if (!is.na(src))
  setwd(paste(wd[1:(src - 1)], collapse = "/"))
source("src/preamble.R")
library(stringr)

# List all files from previous runs
fnames <- list.files(
  path = "out",
  pattern = "083_r[.0-9]+_d[.0-9]+_(random|lattice).csv",
  full.names = TRUE
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
