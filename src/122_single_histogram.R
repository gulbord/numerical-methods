wd <- unlist(strsplit(getwd(), "/"))
src <- match("src", wd)
if (!is.na(src))
  setwd(paste(wd[1:(src - 1)], collapse = "/"))
source("src/preamble.R")

# Select a subset of 5.1 output files between two temperatures
L <- 90
fnames <- list.files(
  path = "out",
  pattern = sprintf("051_L%d", L),
  full.names = TRUE
)
min_temp <- 2.2
max_temp <- 2.3
num_temps <- 6
temps <- as.numeric(sub(".*T([.0-9]+).csv", "\\1", fnames))
mask <- between(temps, min_temp, max_temp)
mask <- which(mask)[seq(1, sum(mask), length.out = num_temps)]
fnames <- fnames[mask]
temps <- temps[mask]

# Read data
eq_time <- 1e4
samples <- lapply(
  seq_along(fnames),
  \(i) list(
    temp = temps[i],
    energy = fread(fnames[i])[(eq_time + 1):.N, energy]
  )
)

temp_seq <- seq(min_temp, max_temp, length.out = 100)
preds <- samples |>
  parallel::mclapply(
    function(x) {
      result <- data.table(temp_in = x$temp, temp_out = temp_seq)
      set(
        result,
        j = "energy",
        value = vapply(
          result$temp_out,
          function(t) {
            boltz <- exp((1 / x$temp - 1 / t) * x$energy)
            return(sum((x$energy / L^2) * boltz) / sum(boltz))
          },
          numeric(1) 
        )
      )
      return(result)
    },
    mc.cores = min(length(samples), getDTthreads())
  ) |>
  rbindlist()

rbindlist(samples)[, energy := energy / L^2] |>
  ggplot(aes(energy, fill = factor(temp))) +
    geom_histogram(bins = 100) |>
    scale_fill_viridis_d()

merge(
  rbindlist(samples)[, .(energy = mean(energy) / L^2, error = sd(energy / L^2))
                     , by = .(temp_in = temp)],
  preds,
  by = "temp_in",
  suffixes = c("_mean", "_pred")
) |>
  ggplot(aes(colour = factor(temp_in))) +
    geom_line(aes(temp_out, energy_pred)) +
    geom_pointrange(
      aes(
        temp_in,
        energy_mean,
        ymin = energy_mean - error,
        ymax = energy_mean + error,
      )
    ) +
    scale_colour_viridis_d()
