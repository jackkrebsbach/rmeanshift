library(devtools)
library(terra)

devtools::clean_dll()
devtools::document()
Rcpp::compileAttributes()
devtools::build()
devtools::install()
devtools::load_all()

rast <- terra::rast("example.jpg")

height <- dim(rast)[1]
width <- dim(rast)[2]
channels <- dim(rast)[3]

img_arr <- as.array(rast)
img_arr <- img_arr[height:1, , , drop = FALSE]
img_arr <- aperm(img_arr, c(3,2,1))
image_flat <- as.vector(img_arr)

result <- rmeanshift::meanshift(image_flat, width, height, channels, 5, 4.5, 200, 2)

result_arr <- array(result, dim = c(3, width, height))
result_arr <- aperm(result_arr, c(3,2,1))
rast_out <- rast(result_arr)

plotRGB(rast_out)




