library(devtools)
library(Rcpp)

if (!requireNamespace("rmeanshift", quietly = TRUE)) {
 devtools::install_github("jackkrebsbach/rmeanshift")
}

library(rmeanshift)

# Terra
library(terra)
img <- terra::rast("example.jpg")
img_array <- terra::as.array(img)
segmented <- rmeanshift::meanshift(img_array, radiusS = 5, radiusR = 4.5, minDensity = 300, speedUp = 2)
img_segmented <- terra::rast(segmented)
terra::plotRGB(img_segmented)

# Imager
library(imager)
img <- imager::load.image("example.jpg")
img_array <- as.array(img)[, , 1, ]
segmented <- rmeanshift::meanshift(img_array, radiusS = 5, radiusR = 4.5, minDensity = 300, speedUp = 2)
img_segmented <- as.cimg(segmented)
plot(img_segmented)

# Magick
library(magick)
img <- magick::image_read("example.jpg")
img_array <- as.numeric(img[[1]])
segmented <- rmeanshift::meanshift(img_array, radiusS = 5, radiusR = 4.5, minDensity = 300, speedUp = 2)
img_segmented <- segmented[dim(segmented)[1]:1, , ] / 255 # Flip and scale image
img_segmented <- magick::image_read(as.raster(img_segmented))
plot(img_segmented)




