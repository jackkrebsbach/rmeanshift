library(devtools)
library(terra)

devtools::clean_dll()
devtools::document()
Rcpp::compileAttributes()
devtools::load_all()

segment <- function(image, spatial_radius = 6, range_radius = 4.5, min_density = 50, speedup_level = 2) {
  if (inherits(image, "SpatRaster")) {
    image_array <- as.array(image)
    dims <- dim(image_array)
  } else if (is.matrix(image) || is.array(image)) {
    image_array <- image
    dims <- dim(image_array)
  } else {
    stop("Unsupported image format. Please provide a SpatRaster, matrix, or array.")
  }
  
  image_vector <- as.integer(image_array)
  
  result <- meanshift(image_vector, dims, spatial_radius, range_radius, min_density, speedup_level)
  result$dims <- dims  
  
  segmented_image <- result$segmentedImage
  
  if (length(dims) == 2) {
    segmented_matrix <- matrix(segmented_image, nrow = dims[1], ncol = dims[2], byrow = TRUE)
  } else if (length(dims) == 3) {
    segmented_matrix <- array(segmented_image, dim = dims)
  }
  
  result$segmentedImage <- terra::rast(segmented_matrix)
  return(result)
}


rast <- terra::rast("/Users/krebsbach/Downloads/Pymeanshift example.jpg")
result <- segment(rast)
segmented_image <- result$segmentedImage

plotRGB(rast)
plotRGB(segmented_image)


