library(ggplot2)
library(patchwork)
theme_set(theme_bw(base_family = "Latin Modern Roman", base_size = 9))
setwd("~/PoD/Y2.1/NMSM/exercises")
my_pal <- c("#0072B2", "#E69F00")

system("rm -f out/07a*")

script <- "exe/07a_wolff"
Tc <- 2 / log(1 + sqrt(2))

plot_emc <- function(L, T, Nt, min_ind = 1, max_ind = 0, teq_e = 0, teq_m = 0) {
    fname <- sprintf("out/07a_L%d_T%.4f_Nt%d.txt", L, T, Nt)
    fread <- file(fname, "rb")
    data <- readBin(fread, what = "double", size = 8, n = 2 * Nt)
    energy <- data[1:Nt]
    magnet <- data[(Nt + 1):(2 * Nt)]
    cl_siz <- readBin(fread, what = "integer", size = 4, n = Nt - 1) / L^2

    mask <- rep(FALSE, Nt)
    if (max_ind == 0) max_ind <- Nt
    mask[min_ind:max_ind] <- TRUE

    energy <- energy[mask]
    magnet <- magnet[mask]
    cl_siz <- cl_siz[mask[seq_len(Nt - 1)]]

    plot_title <- substitute(paste(italic(L), " = ", Lval, ", ",
                                   italic(T), " = ", Tval),
                             list(Lval = L, Tval = format(T, digits = 4)))
    par(mfrow = c(3, 1))
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
    hist(cl_siz, breaks = "FD", freq = TRUE,
         main = NULL,
         xlab = "Cluster size as fraction of N",
         ylab = "Probability density")
    title(plot_title, outer = TRUE, line = -2)
}
