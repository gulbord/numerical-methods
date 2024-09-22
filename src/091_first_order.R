wd <- unlist(strsplit(getwd(), "/"))
src <- match("src", wd)
if (!is.na(src))
  setwd(paste(wd[1:(src - 1)], collapse = "/"))
source("src/preamble.R")

system("exe/091_first_order dt0.01 1.0 0.0 0.01 1000")
system("exe/091_first_order dt0.001 1.0 0.0 0.001 10000")

results <- sprintf("out/091_dt%g.csv", c(0.01, 0.001)) |>
  lapply(
    function(fname) {
      df <- fread(fname) |>
        melt(
          measure.vars = measure(
            value.name,
            algo = as.factor,
            pattern = "(\\w)(\\d)"
          )
        )
      levels(df$algo) <- c("non-symp", "symp")

      return(df)
    }
  ) |>
  rbindlist(idcol = "dt")

plt_err <- copy(results) |>
  _[, let(x = x - cos(time), p = p + sin(time))] |>
  melt(measure.vars = c("x", "p"), variable.name = "coord") |>
  ggplot(aes(time, value, colour = coord)) +
    geom_line() +
    facet_grid(
      rows = vars(dt),
      cols = vars(algo),
      labeller = as_labeller(
        c(
          `1` = "Δ<i>t</i> = 0.01",
          `2` = "Δ<i>t</i>  = 0.001",
          `non-symp` = "Non-symplectic",
          `symp` = "Symplectic"
        )
      )
    ) +
    scale_colour_brewer(
      palette = "Dark2",
      labels = c(x = "<i>x</i>", p = "<i>p</i>"),
    ) +
    labs(
      x = "Time",
      y = "Absolute error",
      colour = "Coordinate",
    ) +
    theme(
      legend.position = "bottom",
      strip.text = ggtext::element_markdown(),
      legend.text = ggtext::element_markdown()
    )

plot_tex("091a", plt_err, asp_ratio = 1, scale_factor = 0.9)

plt_ham <- copy(results) |>
  _[, ham := (x^2 + p^2) / 2] |>
  _[, ham_shad := ham - p * x * fifelse(dt == 1, 0.01, 0.001) / 2] |>
  melt(id.vars = 1:3, measure.vars = patterns("^ham")) |>
  ggplot(aes(time, value, colour = variable)) +
    geom_line() +
    facet_grid(
      rows = vars(dt),
      cols = vars(algo),
      labeller = as_labeller(
        c(
          `1` = "Δ<i>t</i> = 0.01",
          `2` = "Δ<i>t</i> = 0.001",
          `non-symp` = "Non-symplectic",
          `symp` = "Symplectic"
        )
      )
    ) +
    scale_colour_brewer(
      palette = "Dark2",
      labels = c(
        ham = "Hamiltonian",
        ham_shad = "Shadow Hamiltonian"
      )
    ) +
    labs(
      x = "Time",
      y = "Value",
      colour = "Variable",
    ) +
    theme(
      legend.position = "bottom",
      strip.text = ggtext::element_markdown(),
    ) 

plot_tex("091b", plt_ham, asp_ratio = 1, scale_factor = 0.9)
