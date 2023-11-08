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
