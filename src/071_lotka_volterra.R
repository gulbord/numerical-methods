wd <- unlist(strsplit(getwd(), "/"))
src <- match("src", wd)
if (!is.na(src))
  setwd(paste(wd[1:(src - 1)], collapse = "/"))
source("src/preamble.R")

k1 <- 3
k2 <- 0.01
k3 <- 5

run_sim <- function(init_prey, init_pred, max_time) {
  exe <- sprintf(
    "exe/071_lotka_volterra %s %g %g %g %d %d %g",
    sprintf("%d_%d", init_prey, init_pred),
    k1, k2, k3,
    init_prey, init_pred, max_time
  )
  system(exe)
}

plot_ex <- function(
  init_prey, init_pred, max_time, run = FALSE, max_xlim = FALSE
) {
  if (run) run_sim(init_prey, init_pred, max_time)
  fread(sprintf("out/071_%d_%d.csv", init_prey, init_pred)) |>
    setnames(-1, \(n) paste("curr", n, sep = ".")) |>
    _[, let(eq.prey = k3 / k2, eq.pred = k1 / k2)] |>
    melt(
      id.vars = "time",
      measure.vars = measure(value.name, species, sep = ".")
    ) |>
    _[, species := factor(
      species,
      levels = c("prey", "pred"),
      labels = c("Prey", "Predators")
    )] |>
    ggplot(aes(colour = species)) +
      geom_line(aes(time, curr)) +
      geom_line(aes(time, eq), linetype = "dashed") +
      scale_colour_brewer(palette = "Dark2") +
      scale_x_continuous(
        breaks = scales::pretty_breaks(),
        limits = if (max_xlim) c(0, max_time) else c(0, NA),
      ) +
      scale_y_continuous(breaks = scales::pretty_breaks()) +
      labs(x = "Time (s)", y = "Population", colour = "Species")
}

# Example run
# plot_ex(500, 300, 10)

# Run a set of simulations
prey <- c(25, 500, 800)
pred <- c(25, 300, 500, 800)
k1 <- 3
k2 <- 0.01
k3 <- 5
# expand.grid(prey, pred) |>
#  as.matrix() |>
#  apply(1, \(x) run_sim(x[1], x[2], 10))

# Plot everything together with initialization details
plt <- lapply(
  list(1:2, 3:4),
  function(idx) {
    expand.grid(prey = prey, pred = pred[idx]) |>
      as.matrix() |>
      apply(
        1, \(x) list(x[1], x[2], sprintf("out/071_%d_%d.csv", x[1], x[2]))
      ) |>
      lapply(
        function(x) {
          cbind(
            init = sprintf("Prey = %s, predators = %s", x[[1]], x[[2]]),
            fread(x[[3]])
          )
        }
      ) |>
      rbindlist() |>
        setnames(3:4, \(n) paste("curr", n, sep = ".")) |>
        _[order(init, time)] |>
        _[, let(eq.prey = k3 / k2, eq.pred = k1 / k2)] |>
        melt(
          id.vars = c("init", "time"),
          measure.vars = measure(value.name, species, sep = ".")
        ) |>
        _[, species := factor(
          species,
          levels = c("prey", "pred"),
          labels = c("Prey", "Predators")
        )] |>
        ggplot(aes(colour = species)) +
          geom_line(aes(time, curr)) +
          geom_line(aes(time, eq), linetype = "dashed") +
          scale_colour_brewer(palette = "Dark2") +
          scale_x_continuous(
            breaks = scales::pretty_breaks(),
            limits = c(0, 10),
          ) +
          scale_y_continuous(breaks = scales::pretty_breaks()) +
          facet_wrap(vars(init), ncol = 2, scales = "free") +
          labs(x = "Time (s)", y = "Population", colour = "Species") +
          theme(legend.position = "bottom")
  }
)

plot_tex("071a", plt[[1]], asp_ratio = 0.85, scale_factor = 1)
plot_tex("071b", plt[[2]], asp_ratio = 0.85, scale_factor = 1)

k1 <- 3
k2 <- 0.01
k3 <- 4
plt_4 <- plot_ex(500, 25, 10, run = TRUE)
plot_tex("071c", plt_4, asp_ratio = 5 / 3, scale_factor = 0.9)

k3 <- 2
plt_2 <- plot_ex(500, 25, 10, run = TRUE)
plot_tex("071d", plt_2, asp_ratio = 5 / 3, scale_factor = 0.9)
