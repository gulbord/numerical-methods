library(tidyverse)
theme_set(theme_minimal(base_family = "STIX Two Text", base_size = 9))
my_blue <- "#002E63"
my_red <- "#9E2B25"
my_grey <- "#798086"

# A01b_disk_hit_miss
read_tsv("../out/A01b.txt", col_names = c("throws", "error")) |>
    mutate(error = 100 * error) |>
    ggplot(aes(throws, error)) +
        geom_line(linewidth = 0.2, colour = my_blue) +
        labs(x = "Number of throws", y = "Error (%)")

ggsave(
    "../tex/img/A01b.svg",
    width = 10, height = 7.5, unit = "cm",
)

# A02a_inversion_method
x <- seq(0, 1, length.out = 5000)
fx <- 4 * x^3
smp <- readBin("../out/A02a_3.txt", what = "double", size = 8, n = 1e5)
ggplot() +
    geom_histogram(
        aes(smp, after_stat(density), fill = "hist"),
        bins = 80,
        boundary = 0,
        alpha = 0.5,
        linewidth = 0,
    ) +
    geom_line(aes(x, fx, colour = "pdf")) +
    scale_fill_manual(values = my_blue, labels = "Simulated data") +
    scale_colour_manual(values = my_blue, labels = "PDF") +
    labs(x = expression(italic("x")), y = expression(italic("ρ₃(x)"))) +
    theme(
        legend.title = element_blank(),
        legend.position = c(0.2, 0.8),
        legend.spacing.y = unit(0, "pt"),
    )

ggsave(
    "../tex/img/A02a_3.svg",
    width = 10, height = 7.5, unit = "cm",
)

# A02b_inversion_method
smp <- readBin("../out/A02b.txt", what = "double", size = 8, n = 1e5)
x <- seq(0, 2, length.out = 1e4)
fx <- 3 * x^2 / 8
ggplot() +
    geom_histogram(
        aes(smp, after_stat(density), fill = "hist"),
        bins = nclass.FD(smp),
        boundary = 0,
        alpha = 0.5,
        linewidth = 0,
    ) +
    geom_line(aes(x, fx, colour = "pdf")) +
    scale_fill_manual(values = my_blue, labels = "Simulated data") +
    scale_colour_manual(values = my_blue, labels = "PDF") +
    labs(x = expression(italic("x")), y = expression(italic("ρ(x)"))) +
    theme(
        legend.title = element_blank(),
        legend.position = c(0.2, 0.8),
        legend.spacing.y = unit(0, "pt"),
    )

ggsave(
    "../tex/img/A02b.svg",
    width = 10, height = 7.5, unit = "cm",
)

# A03aa_disk_naive
smp <- readBin("../out/A03aa.txt", what = "double", size = 8, n = 2e4)
r <- smp[1:1e4]
t <- smp[(1e4 + 1):length(smp)]
x <- r * cos(t)
y <- r * sin(t)
t_line <- seq(0, 2 * pi, length.out = 2000)
ggplot() +
    geom_path(aes(cos(t_line), sin(t_line)), colour = my_grey) +
    geom_point(aes(x, y), colour = my_blue, size = 0.05) +
    labs(x = expression(italic("x")), y = expression(italic("y")))

ggsave(
    "../tex/img/A03aa.svg",
    width = 7, height = 7, unit = "cm"
)

# A03ab_disk_correct
smp <- readBin("../out/A03ab.txt", what = "double", size = 8, n = 2e4)
r <- smp[1:1e4]
t <- smp[(1e4 + 1):length(smp)]
x <- r * cos(t)
y <- r * sin(t)
t_line <- seq(0, 2 * pi, length.out = 2000)
ggplot() +
    geom_path(aes(cos(t_line), sin(t_line)), colour = my_grey) +
    geom_point(aes(x, y), colour = my_blue, size = 0.05) +
    labs(x = expression(italic("x")), y = expression(italic("y")))

ggsave(
    "../tex/img/A03ab.svg",
    width = 7, height = 7, unit = "cm"
)

# A03b_box_muller
smp <- readBin("../out/A03b.txt", what = "double", size = 8, n = 1e5)
x <- seq(min(smp), max(smp), by = 0.001)
fx <- dnorm(x, 2, 3)
ggplot() +
    geom_histogram(
        aes(smp, after_stat(density), fill = "hist"),
        bins = nclass.FD(smp),
        boundary = 0,
        alpha = 0.5,
        linewidth = 0,
    ) +
    geom_line(aes(x, fx, colour = "pdf")) +
    scale_fill_manual(values = my_blue, labels = "Simulated data") +
    scale_colour_manual(values = my_blue, labels = "PDF") +
    labs(
        x = expression(italic("x")),
        y = expression(
            paste("Gaussian with ", italic("μ"), " = 2, ", italic("σ"), " = 3")
        ),
    ) +
    theme(
        legend.title = element_blank(),
        legend.position = c(0.2, 0.8),
        legend.spacing.y = unit(0, "pt"),
    )

ggsave(
    "../tex/img/A03b.svg",
    width = 10, height = 7.5, unit = "cm",
)

# A03ca_rejection_sampling
smp <- readBin("../out/A03ca.txt", what = "double", size = 8, n = 1e5)
x <- seq(0, max(smp), by = 0.0005)
fx <- 2 * exp(-x^2) / sqrt(pi)
ggplot() +
    geom_histogram(
        aes(smp, after_stat(density), fill = "hist"),
        bins = nclass.FD(smp),
        boundary = 0,
        alpha = 0.5,
    ) +
    geom_line(aes(x, fx, colour = "pdf")) +
    scale_fill_manual(values = my_blue, labels = "Simulated data") +
    scale_colour_manual(values = my_blue, labels = "PDF") +
    labs(
        x = expression(italic("x")),
        y = expression(paste(italic("f"), "(", italic("x"), ")")),
    ) +
    theme(
        legend.title = element_blank(),
        legend.position = c(0.8, 0.8),
        legend.spacing.y = unit(0, "pt"),
    )

ggsave(
    "../tex/img/A03ca.svg",
    width = 10, height = 7.5, unit = "cm",
)

# A03cb_rejection_analysis
smp <- readBin("../out/A03cb.txt", what = "double", size = 8, n = 1e4)
p <- smp[1:(length(smp) / 2)]
acc <- smp[(length(smp) / 2 + 1):length(smp)]
ggplot() +
    geom_line(aes(p, acc), linewidth = 0.1, colour = my_blue) +
    labs(x = expression(italic("p")), y = "Acceptance rate")

ggsave(
    "../tex/img/A03cb.svg",
    width = 10, height = 7.5, unit = "cm",
)

# A04a_gauss_crude_vs_import
smp <- readBin("../out/A04a.txt", what = "double", size = 8, n = 201 * 450) |>
    matrix(ncol = 201, byrow = TRUE)
smp[, -1] <- 100 * abs(1 - smp[, -1] / 0.25)
smp <- as.data.frame(smp) |>
    rename_with(~ "n", 1) |>
    rowwise() |>
    mutate(
        m_crude = mean(c_across(2:101)),
        sd_crude = sd(c_across(2:101)),
        m_impor = mean(c_across(102:201)),
        sd_impor = sd(c_across(102:201)),
    ) |>
    select(n, ends_with("crude"), ends_with("impor")) |>
    pivot_longer(
        cols = -1,
        names_to = c(".value", "method"),
        names_pattern = "(.*)_(.*)",
    )
ggplot(smp, aes(n, m)) +
    geom_line(aes(colour = method), linewidth = 0.1) +
    geom_ribbon(aes(fill = method, ymin = m - sd, ymax = m + sd), alpha = 0.5) +
    scale_colour_manual(
        values = c(my_red, my_blue),
        labels = c("Crude", "Importance sampling"),
    ) +
    scale_fill_manual(
        values = c(my_red, my_blue),
        labels = c("Crude", "Importance sampling"),
    ) +
    labs(
        x = "Number of iterations",
        y = "Error (%)",
        colour = "Monte Carlo method",
        fill = "Monte Carlo method",
    ) +
    theme(
        legend.position = c(0.7, 0.8),
        # remove spacing between labels, but not between title and first label
        legend.text = element_text(margin = margin(t = 0, unit = "pt")),
    )

ggsave(
    "../tex/img/A04a.svg",
    width = 10, height = 7.5, unit = "cm",
)

# A04b_cosx_importance
smp <- readBin("../out/A04b.txt", what = "double", size = 8, n = 100 * 101) |>
    matrix(ncol = 101, byrow = TRUE)
smp[, -1] <- 100 * abs(1 - smp[, -1])
smp <- as.data.frame(smp) |>
    rename_with(~ "n", 1) |>
    rowwise() |>
    mutate(m = mean(c_across(-1)), sd = sd(c_across(-1))) |>
    select(n, m, sd)
ggplot(smp, aes(n, m)) +
    geom_line(colour = my_blue, linewidth = 0.1) +
    geom_ribbon(
        aes(ymin = m - sd, ymax = m + sd),
        fill = my_blue,
        alpha = 0.5,
    ) +
    scale_x_continuous(breaks = scales::pretty_breaks()) +
    labs(x = "Number of iterations", y = "Error (%)")

ggsave(
    "../tex/img/A04b.svg",
    width = 10, height = 7.5, unit = "cm",
)

# A04c
T <- seq(1, 20, length.out = 5000)
var_rho <- function(t) sqrt(exp(t) - 1)
var_g <- function(t) {
    a <- (1 + t - sqrt(1 + t^2)) / t
    return(sqrt(exp(a * t) / (a * (2 - a)) - 1))
}
ggplot() +
    geom_line(aes(T, var_rho(T) / var_g(T)), colour = my_blue) +
    labs(x = expression(italic("T")), y = "Variance ratio")

ggsave(
    "../tex/img/A04c.svg",
    width = 8, height = 6, unit = "cm",
)

