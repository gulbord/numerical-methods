setwd("~/PoD/Y2.1/NMSM/exercises")
source("src/preamble.R")

a <- 2
b <- 5

run_sim <- function(omega, init_x, init_y, max_time) {
  exe <- sprintf(
    "exe/072_brusselator %s %g %g %g %d %d %g",
    sprintf("%g_%d_%d", omega, init_x, init_y),
    a, b, omega, init_x, init_y, max_time
  )
  system(exe)
}

plot_ex <- function(omega, init_x, init_y, max_time, run = TRUE) {
  if (run) run_sim(omega, init_x, init_y, max_time)
  fread(sprintf("out/072_%g_%d_%d.csv", omega, init_x, init_y)) |>
    melt(id.vars = "time") |>
    ggplot() +
      geom_line(aes(time, value, colour = variable)) +
      scale_colour_brewer(palette = "Dark2") +
      scale_x_continuous(breaks = scales::pretty_breaks()) +
      scale_y_continuous(breaks = scales::pretty_breaks()) +
      labs(x = "Time (s)", y = "Number of molecules", colour = "Species")
}

# plot_ex(100, 300, 250, 20)

# system("rm out/072*")

omega <- c(1e2, 1e3, 1e4)
starts <- expand.grid(omega = omega, init_x = c(0.5, 2), init_y = c(1, 2.5)) |>
  as.data.table() |>
  _[, let(init_x = init_x * omega, init_y = init_y * omega)]
  
# apply(starts, 1, \(x) run_sim(x[1], x[2], x[3], 15))

results <- apply(
  starts, 1,
  function(x) {
    cbind(
      omega = x[1],
      init = sprintf(
        "<i>X</i><sub>0</sub> = %d. <i>Y</i><sub>0</sub> = %d",
        x[2], x[3]
      ),
      fread(sprintf("out/072_%g_%d_%d.csv", x[1], x[2], x[3]))
    )
  }
) |>
  rbindlist()

plt <- lapply(
  omega,
  function(w) {
    starts[omega == w] |>
      apply(
        1, function(x) {
          cbind(
            init =  sprintf(
              "<i>X</i><sub>0</sub> = %d, <i>Y</i><sub>0</sub> = %d",
              x[2], x[3]
            ),
            fread(sprintf("out/072_%g_%d_%d.csv", x[1], x[2], x[3]))
          )
        }
      ) |>
      rbindlist() |>
      _[sample(1:.N, size = 5e4)] |> # Subsample a bit
      setnames(c("X", "Y"), c("curr.X", "curr.Y")) |>
      _[, let(eq.X = a * w, eq.Y = b * w / a)] |>
      melt(
        id.vars = c("init", "time"),
        measure.vars = measure(value.name, species, sep = ".")
      ) |>
      _[, species := factor(
        species,
        levels = c("X", "Y"),
        labels = c("<i>X</i>", "<i>Y</i>")
      )] |>
      ggplot(aes(colour = species)) +
        geom_line(aes(time, eq), linetype = "dashed") +
        geom_line(aes(time, curr)) +
        scale_colour_brewer(palette = "Dark2") +
        scale_x_continuous(breaks = scales::pretty_breaks()) +
        scale_y_continuous(breaks = scales::pretty_breaks()) +
        facet_wrap(vars(init)) +
        labs(
          x = "Time (s)",
          y = "Number of molecules",
          colour = "Species"
        ) +
        theme(
          legend.position = "bottom",
          legend.text = ggtext::element_markdown(),
          strip.text = ggtext::element_markdown(),
        )
  }
)

plot_tex("072a", plt[[1]], asp_ratio = 1, scale_factor = 1)
plot_tex("072b", plt[[2]], asp_ratio = 1, scale_factor = 1)
plot_tex("072c", plt[[3]], asp_ratio = 1, scale_factor = 1)
