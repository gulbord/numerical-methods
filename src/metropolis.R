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

plot_em <- function(L, T, Nt, max_ind = -1, teq_e = 0, teq_m = 0) {
    fname <- sprintf("A06a_L%d_T%.4f_Nt%d", L, T, Nt)
    data <- readBin(sprintf("out/%s.txt", fname),
                    what = "double", size = 8, n = 2 * Nt)
    energy <- data[1:Nt]
    magnet <- data[(Nt + 1):(2 * Nt)]

    if (max_ind > 1) {
        energy <- energy[1:max_ind]
        magnet <- magnet[1:max_ind]
    }

    plot_title <- substitute(paste(italic(L), " = ", Lval, ", ",
                                   italic(T), " = ", Tval),
                             list(Lval = L, Tval = format(T, digits = 4)))
    par(mfrow = c(2, 1))
    plot(energy, type = "l",
         xlab = "Time (MC steps per spin)",
         ylab = "Energy per spin")
    if (teq_e > 0)
        abline(v = teq_e, col = "red")
    plot(magnet, type = "l",
         xlab = "Time (MC steps per spin)",
         ylab = "Magnetization per spin")
    if (teq_m > 0)
        abline(v = teq_m, col = "red")
    title(plot_title, outer = TRUE, line = -2)
}

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
