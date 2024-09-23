wd <- unlist(strsplit(getwd(), "/"))
src <- match("src", wd)
if (!is.na(src))
  setwd(paste(wd[1:(src - 1)], collapse = "/"))
source("src/preamble.R")

# k and m for the 'unstable' case
k_uns <- 312.5
m_uns <- 0.5
omega_uns <- sqrt(k_uns / m_uns)
dt <- 0.1
message(omega_uns * dt)
max_time <- 10
system(
  sprintf(
    "exe/092_higher_order stable 1.0 1.0 1.0 0.0 %f %d",
    dt, floor(max_time / dt)
  )
)
system(
  sprintf(
    "exe/092_higher_order unstable %f %f 1.0 0.0 %f %d",
    k_uns, m_uns, dt, floor(max_time / dt)
  )
)

results <- lapply(
  c("out/092_stable.csv", "out/092_unstable.csv"),
  \(f) melt(fread(f), measure.vars = measure(value.name, algo, sep = "_"))
)

km <- matrix(c(1, k_uns, 1, m_uns), ncol = 2)

plt_err <- rbindlist(results, idcol = "run") |>
  _[, omega := sqrt(km[run, 1] / km[run, 2])] |>
  _[, let(x = x - cos(omega * time),
          p = p + km[run, 2] * omega * sin(omega * time))] |>
  melt(id.vars = 1:3, measure.vars = c("x", "p"), variable.name = "coord") |>
  ggplot(aes(time, value, colour = coord)) +
    geom_line() +
    facet_grid(
      rows = vars(run),
      cols = vars(algo),
      scales = "free",
      labeller = as_labeller(
        c(
          beeman = "Beeman",
          vverlet = "Velocity Verlet",
          `1` = paste("<i>ω</i> Δ<i>t</i> =", dt),
          `2` = paste("<i>ω</i> Δ<i>t</i> =", omega_uns * dt)
        )
      )
    ) +
    scale_colour_brewer(
      palette = "Dark2",
      labels = c(x = "<i>x</i>", p = "<i>p</i>"),
    ) +
    labs(x = "Time", y = "Absolute error", colour = "Coordinate") +
    theme(
      legend.position = "bottom",
      strip.text = ggtext::element_markdown(),
      legend.text = ggtext::element_markdown(),
    )

plot_tex("093a", plt_err, asp_ratio = 1, scale_factor = 0.9)

plt_ham <- rbindlist(results, idcol = "run") |>
  _[, ham := (p^2 / km[run, 2] + km[run, 1] * x^2) / 2] |>
  _[, ham := 100 * (ham - ham[1]) / ham[1], by = .(run, algo)] |>
  ggplot(aes(time, ham)) +
    geom_line() +
    facet_grid(
      rows = vars(run),
      cols = vars(algo),
      scales = "free",
      labeller = as_labeller(
        c(
          beeman = "Beeman",
          vverlet = "Velocity Verlet",
          `1` = paste("<i>ω</i> Δ<i>t</i> =", dt),
          `2` = paste("<i>ω</i> Δ<i>t</i> =", omega_uns * dt)
        )
      )
    ) +
    labs(x = "Time", y = "Relative difference from initial energy (%)") +
    theme(strip.text = ggtext::element_markdown())

plot_tex("093b", plt_ham, asp_ratio = 1, scale_factor = 0.9)
