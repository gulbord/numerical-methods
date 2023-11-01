library(data.table)
library(ggplot2)
theme_set(theme_bw(base_family = "Fira Sans Condensed", base_size = 16))

raw_data <- readBin("../out/0204b.txt", what = "double", size = 8, n = 1e6)
df <- data.table(matrix(raw_data, ncol = 11, byrow = TRUE))

# convert to errors w.r. to true integral (= 1)
df[, 2:ncol(df)] <- 100 * abs(1 - df[, -1])

rowSds <- function(x) sqrt(rowSums((x - rowMeans(x))^2) / (ncol(x) - 1))

df <- df[, .(n = V1, mean = rowMeans(df[, -1]), sd = rowSds(df[, -1]))]

ggplot(df, aes(x = n, y = mean)) +
    geom_ribbon(
        aes(ymin = mean - sd, ymax = mean + sd),
        alpha = 0.5,
        fill = "darkseagreen3",
        colour = "transparent",
    ) +
    geom_line(colour = "aquamarine4", lwd = 0.7) +
    scale_y_continuous(breaks = scales::pretty_breaks()) +
    labs(x = "Number of iterations", y = "Error (%)")
