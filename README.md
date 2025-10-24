# Meanshift: a robust approach toward feature space analysis.

This package provides an R interface to the Mean Shift algorithm implemented in C++ by D. Comaniciu and P. Meer. The input must be a 3D array with last dimension representing the number of channels/bands. The output is an array of the same dimensions as the input. See examples below.

| Original                 | Segmented                           |
|--------------------------|-------------------------------------|
| ![Original](example.jpg) | ![Segmented](example_segmented.jpg) |

The original paper can be found at: <https://ieeexplore.ieee.org/document/1000236/>

The original C++ code can be found at: <https://cecas.clemson.edu/~stb/blepo/>

## Installation

The **Rcpp** R package is required to install **rmeanshift**.

``` r
library(Rcpp)

## Devtools
library(devtools)
devtools::install_github("jackkrebsbach/rmeanshift")

## Remotes
library(remotes)
remotes::install_github("jackkrebsbach/rmeanshift")
```

## Example

### Terra

``` r
library(devtools)
library(Rcpp)

if (!requireNamespace("rmeanshift", quietly = TRUE)) {
 devtools::install_github("jackkrebsbach/rmeanshift")
}

library(rmeanshift)
library(terra)

img <- terra::rast("example.jpg")
img_array <- terra::as.array(img)
segmented <- rmeanshift::meanshift(img_array, radiusS = 5, radiusR = 4.5, minDensity = 300, speedUp = 2)
img_segmented <- terra::rast(segmented)
terra::plotRGB(img_segmented)
```

### Imager

``` r
library(devtools)
library(Rcpp)

if (!requireNamespace("rmeanshift", quietly = TRUE)) {
 devtools::install_github("jackkrebsbach/rmeanshift")
}

library(rmeanshift)
library(imager)

img <- imager::load.image("example.jpg")
img_array <- as.array(img)[, , 1, ]
segmented <- rmeanshift::meanshift(img_array, radiusS = 5, radiusR = 4.5, minDensity = 300, speedUp = 2)
img_segmented <- as.cimg(segmented)
plot(img_segmented)
```

### Magick

``` r
library(devtools)
library(Rcpp)

if (!requireNamespace("rmeanshift", quietly = TRUE)) {
 devtools::install_github("jackkrebsbach/rmeanshift")
}

library(rmeanshift)
library(magick)

img <- magick::image_read("example.jpg")
img_array <- as.numeric(img[[1]])
segmented <- rmeanshift::meanshift(img_array, radiusS = 5, radiusR = 4.5, minDensity = 300, speedUp = 2)
img_segmented <- segmented[dim(segmented)[1]:1, , ] / 255 # Flip and scale image
img_segmented <- magick::image_read(as.raster(img_segmented))
plot(img_segmented)
```
