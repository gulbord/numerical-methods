library(tidyverse)
library(deSolve)
theme_set(theme_bw(base_family = "Latin Modern Roman", base_size = 9))
setwd("~/PoD/Y2.1/NMSM/exercises")
my_pal <- c("#0072B2", "#E69F00")

system("rm -f out/08a*")

k_birth <- 3
k_pred <- 0.01
k_death <- 5
init_prey <- 500
init_pred <- 300
max_time <- 8
system(sprintf("exe/08a_lotka_volterra %g %g %g %d %d %g",
               k_birth, k_pred, k_death, init_prey, init_pred, max_time))

fname <- sprintf("out/08a_Ka%g_Kb%g_Kc%g_X%d_Y%d_T%g.txt",
                 k_birth, k_pred, k_death, init_prey, init_pred, max_time)
data <- read_csv(fname, show_col_types = FALSE,
                 col_names = c("time", "prey", "predator"))

lv_mod <- function(time, state, pars) {
    with(as.list(c(state, pars)), {
        prey_birth <- k_birth * prey
        predation <- k_pred * prey * predator
        pred_death <- k_death * predator

        d_prey <- prey_birth - predation 
        d_predator <- predation - pred_death

        return(list(c(d_prey, d_predator)))
    })
}

pars <- c(k_birth = k_birth, k_pred = k_pred, k_death = k_death)
init <- c(prey = init_prey, predator = init_pred)
times <- data$time
data_det <- ode(init, times, lv_mod, pars) |>
    as.data.frame() |>
    pivot_longer(-time, names_to = "species", values_to = "deterministic")

data <- data |>
    pivot_longer(-time, names_to = "species", values_to = "stochastic") |>
    inner_join(data_det, join_by(time, species)) |>
    pivot_longer(stochastic:deterministic,
                 names_to = "solution", values_to = "population") |>
    mutate(species = fct_relevel(species, "prey", "predator"),
           solution = fct_relevel(solution, "stochastic", "deterministic"))

ggplot(data) +
    geom_line(aes(time, population, colour = species, linetype = solution),
              linewidth = 0.3) +
    scale_linetype_manual(values = c("solid", "11"),
                          labels = c("Stochastic", "Deterministic")) +
    scale_colour_manual(values = my_pal,
                        labels = c("Prey", "Predator")) +
    labs(x = "Time (s)", y = "Population",
         colour = "Species", linetype = "Solution")

ggsave("tex/img/08a.svg", width = 13, height = 7.5, unit = "cm")

###############
# BRUSSELATOR #
###############

system("rm -f out/08b*")

a <- 2
b <- 5
omega <- 1000
init_x <- 2000
init_y <- 3000
max_time <- 20
system(sprintf("exe/08b_brusselator %g %g %g %d %d %g",
               a, b, omega, init_x, init_y, max_time))

fname <- sprintf("out/08b_a%g_b%g_O%g_X%d_Y%d_T%g.txt",
                 a, b, omega, init_x, init_y, max_time)
data <- read_csv(fname, show_col_types = FALSE,
                 col_names = c("time", "x", "y"))

data |>
    pivot_longer(-time, names_to = "species", values_to = "population") |>
    ggplot() +
        geom_line(aes(time, population, colour = species), linewidth = 0.3) +
        scale_colour_manual(values = my_pal, labels = c("X", "Y")) +
        labs(x = "Time (s)", y = "Number of molecules", colour = "Species")
