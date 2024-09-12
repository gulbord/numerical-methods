wd <- unlist(strsplit(getwd(), "/"))
src <- match("src", wd)
if (!is.na(src))
  setwd(paste(wd[1:(src - 1)], collapse = "/"))
source("src/preamble.R")
library(stringr)

Tc <- 2 / log(1 + sqrt(2))
temp_step <- 0.01
num_temps <- 20
temps <- c(
  seq(to = Tc - temp_step, by = temp_step, length.out = num_temps %/% 2),
  seq(from = Tc, by = temp_step, length.out = num_temps - num_temps %/% 2)
)
sides <- c(25, 50, 75)
num_steps <- 1e5

# for (side in sides) {
#   for (temp in temps) {
#     message(sprintf("Processing L = %d, T = %g", side, temp))
#     fname <- sprintf("L%d_T%g", side, temp)
#     system(
#       sprintf(
#         "exe/051_ising_metropolis %s %d %f %d",
#         fname, side, temp, num_steps
#       )
#     )
#   }
# }

eq_time <- 5000

fnames <- expand.grid(sides, temps) |>
  apply(1, \(x) sprintf("out/051_L%d_T%g.csv", x[1], x[2]))

enemag <- lapply(
  fnames,
  function(fname) {
    side <- as.integer(str_extract(fname, "(?<=L)\\d+"))
    temp <- as.numeric(str_extract(fname, "(?<=T)\\d+\\.?\\d+"))
    df <- fread(fname)[(eq_time + 1):.N]
    df[, let(magnet = abs(magnet) / side^2, energy = energy / side^2)]
    N <- nrow(df)

    results <- lapply(
      names(df),
      function(col) {
        acf <- acf_fft(df[[col]], max_lag = 250, thr = 0.005)
        tau <- sum((1 - seq_along(acf) / N) * acf)

        return(
          list(
            obs = col,
            mean = mean(df[[col]]),
            sd = sd(df[[col]]) * sqrt(1 + 2 * tau),
            tau = tau
          )
        )
      }
    )

    return(cbind(side = side, temp = temp, rbindlist(results)))
  }
) |>
  rbindlist()

ggplot(enemag, aes(colour = factor(side), fill = factor(side))) +
  #geom_ribbon(aes(temp, ymin = mean - sd, ymax = mean + sd)) +
  geom_line(aes(temp, mean)) +
  facet_wrap(vars(obs), nrow = 2, scales = "free_y")
