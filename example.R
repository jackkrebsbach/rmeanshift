library(devtools)
library(terra)
library(Rcpp)

if (!requireNamespace("rmeanshift", quietly = TRUE)) {
 devtools::install_github("jackkrebsbach/rmeanshift")
}

library(rmeanshift)

img <- terra::rast("example.jpg")

result <- rmeanshift::meanshift(img, radiusS =  5, radiusR = 4.5, minDensity =  200)

terra::plotRGB(result)




