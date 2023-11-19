library(ggplot2)
library(patchwork)
theme_set(theme_minimal(base_family = "STIX Two Text", base_size = 9))
my_blue <- "#002E63"
my_red <- "#9E2B25"
my_grey <- "#798086"

setwd("~/PoD/Y2.1/NMSM/exercises")
system("rm -f out/A06a*")

script <- "exe/A06a_metropolis_simulation"
Tc <- 2 / log(1 + sqrt(2))
Nt <- 1e5
iter <- seq_len(Nt)

for (L in c(25, 50, 100)) {
    for (T in c(Tc / 2, Tc + 0.01, 2 * Tc)) {
        message(sprintf("L = %d, T = %.4f", L, T))
        # call script
        system(sprintf("%s %d %f %d", script, L, T, Nt))
        fname <- sprintf("A06a_L%d_T%.4f_Nt%d", L, T, Nt)
        # read output data
        data <- readBin(sprintf("out/%s.txt", fname),
                        what = "double", size = 8, n = 2 * Nt)
        energy <- data[1:Nt]
        magnet <- data[(Nt + 1):(2 * Nt)]
        # build plots
        e_plot <- ggplot() +
            geom_line(aes(iter, energy), linewidth = 0.1, colour = my_blue) +
            labs(x = "Time (MC steps per spin)", y = "Energy per spin")
        m_plot <- ggplot() +
            geom_line(aes(iter, magnet), linewidth = 0.1, colour = my_blue) +
            labs(x = "Time (MC steps per spin)", y = "Magnetization per spin")
        plot_title <- substitute(paste(italic(L), " = ", Lval, ", ",
                                       italic(T), " = ", Tval),
                                 list(Lval = L, Tval = format(T, digits = 4)))
        em_plot <- e_plot / m_plot +
            plot_annotation(title = plot_title,
                            theme = theme(plot.title = element_text(size = 11)))
        # save image
        ggsave(sprintf("tex/img/%s.svg", fname), plot = em_plot,
               width = 10, height = 15, unit = "cm")
    }
}

stat_ineff <- function(a, min_t = 3) {
    # Reference: J. D. Chodera, W. C. Swope, J. W. Pitera, C. Seok, and K. A.
    # Dill. Use of the weighted histogram analysis method for the analysis of
    # simulated and parallel tempering simulations. JCTC 3(1):26-41, 2007.

    # fluctuations from the mean
    da <- a - mean(a)

    t_run <- length(a)
    var_a <- var(a)
    g <- 0
    t <- 1
    while (t < t_run - 1) {
        # compute normalized acf at lag t
        c <- sum(da[1:(t_run - t)] * da[(t + 1):t_run]) / ((t_run - t) * var_a)

        # terminate if c has crossed zero and we've at least lag = min_t
        if (c < 0 && t > min_t)
            break

        # accumulate contribution to statistical inefficiency g
        g <- g + (1 - t / t_run) * c
        t <- t + 1
    }
 
    return(1 + 2 * g)
}

n_eff <- function(a, t) {
    n <- length(a)
    return((n - t + 1) / stat_ineff(a[t:n]))
}

