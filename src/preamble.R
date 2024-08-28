library(data.table)
library(ggplot2)
tex_pt <- 72 / 72.27        # 1 inch is 72.27 (TeX) pt, but only 72 'normal' pts
textwidth <- 383 * 0.035146 # Conversion factor for pt (TeX) to cm
theme_set(theme_bw(
  base_family = "TeX Gyre Pagella",
  base_size = 9 * 72 / 72.27
))

plot_tex <- function(basename, plt, asp_ratio = 4 / 3, scale_factor = 0.8) {
  filename <- paste0("./tex/img/", basename, ".png")
  ggplot2::ggsave(
    filename,
    plt,
    width = scale_factor * textwidth,
    height = scale_factor * textwidth / asp_ratio,
    units = "cm",
    dpi = 600,
  )
  knitr::plot_crop(filename)
}
