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

# Recover densities and max. disp. from list of files
rho <- fnames |>
  str_extract("(?<=r)[.0-9]+") |>
  unique() |>
  as.numeric() |>
  sort()
dmax <- fnames |>
  str_extract("(?<=d)[.0-9]+") |>
  unique() |>
  as.numeric() |>
  sort()

fnames[15] |>
  fread() |>
  _[, acc_ratio := NULL] |>
  _[sample(1:.N, 1e5L)] |>
  _[, iter := 1:.N, by = realization] |>
  _[, energy := energy / 1e6] |>
  ggplot(aes(iter, energy, group = realization)) +
    geom_line(alpha = 0.5)
