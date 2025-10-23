library(devtools)
library(terra)

devtools::clean_dll()
devtools::document()
Rcpp::compileAttributes()
devtools::build()
devtools::install()
devtools::load_all()

rast <- terra::rast("example.jpg")

result <- rmeanshift::meanshift(image_flat, 5, 4.5, 200, 2)

result_arr <- array(result, dim = c(3, width, height))
result_arr <- aperm(result_arr, c(3,2,1))
rast_out <- rast(result_arr)

plotRGB(rast_out)




