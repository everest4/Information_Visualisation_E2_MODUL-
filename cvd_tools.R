# =============================================================================
#  cvd_tools.R -- check a chart for colour-vision deficiency (CVD)
#
#    source("cvd_tools.R")
#    cvd_check("redesign.png")   # writes redesign_cvd.png (4 panels)
#
#  For a palette only:  colorspace::swatchplot(my_colours, cvd = TRUE)
#
#  Simulation: Machado, Oliveira & Fernandes (2009), severity 100%, in linear
#  RGB (the same matrices as the colorspace package). Greyscale: relative
#  luminance (Rec. 709 weights). Needs the "png" package.
# =============================================================================
cvd_matrices <- list(
  "Deuteranopia (no green cones)" = matrix(c(
     0.367322, 0.860646, -0.227968,
     0.280085, 0.672501,  0.047413,
    -0.011820, 0.042940,  0.968881), 3, byrow = TRUE),
  "Protanopia (no red cones)" = matrix(c(
     0.152286,  1.052583, -0.204868,
     0.114503,  0.786281,  0.099216,
    -0.003882, -0.048116,  1.051998), 3, byrow = TRUE)
)

.to_linear <- function(x) ifelse(x <= 0.04045, x / 12.92, ((x + 0.055) / 1.055)^2.4)
.to_srgb <- function(x) {
  x <- pmin(pmax(x, 0), 1)
  ifelse(x <= 0.0031308, 12.92 * x, 1.055 * x^(1 / 2.4) - 0.055)
}

simulate_cvd_image <- function(img, kind) {
  d <- dim(img)
  rgb <- matrix(.to_linear(img[, , 1:3]), ncol = 3)        # one row per pixel
  out <- if (kind == "Greyscale") {
    y <- rgb %*% c(0.2126, 0.7152, 0.0722)
    cbind(y, y, y)
  } else {
    rgb %*% t(cvd_matrices[[kind]])
  }
  array(.to_srgb(out), dim = c(d[1], d[2], 3))
}

cvd_check <- function(png_file, out_file = NULL) {
  if (!requireNamespace("png", quietly = TRUE))
    stop("Please install the 'png' package: run setup/install_R_packages.R")
  img <- png::readPNG(png_file)
  if (length(dim(img)) == 2) img <- array(rep(img, 3), dim = c(dim(img), 3))
  kinds <- c("Original", names(cvd_matrices), "Greyscale")
  panels <- lapply(kinds, function(k)
    if (k == "Original") img[, , 1:3] else simulate_cvd_image(img, k))
  if (is.null(out_file)) out_file <- sub("\\.png$", "_cvd.png", png_file)
  h <- dim(img)[1]; w <- dim(img)[2]
  png(out_file, width = 2 * w, height = 2 * h + 120)
  op <- par(mfrow = c(2, 2), mar = c(0, 0, 1.6, 0))
  on.exit({ par(op); dev.off() }, add = TRUE)
  for (i in seq_along(kinds)) {
    plot.new(); plot.window(c(0, w), c(0, h), asp = 1)
    rasterImage(panels[[i]], 0, 0, w, h)
    title(kinds[i], adj = 0, cex.main = 2.4)
  }
  message("CVD check written to ", out_file)
  invisible(out_file)
}
