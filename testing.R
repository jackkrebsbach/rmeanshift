library(devtools)
library(terra)

devtools::clean_dll()
devtools::document()
Rcpp::compileAttributes()
devtools::load_all()


segment <- function(image, spatial_radius = 6, range_radius = 4.5, min_density = 60, speedup = 2) {
  if (inherits(image, "SpatRaster")) {
    image_array <- terra::as.array(image)
  } else if (is.matrix(image) || is.array(image)) {
    image_array <- image
  } else {
    stop("Unsupported image format. Please provide a SpatRaster, matrix, or array.")
  }
  
  # Get dimensions
  dims <- dim(image_array)
  
  # Call the Rcpp function
  result <- meanshift(image_array, spatial_radius, range_radius, min_density, speedup)
  
  # Reshape the segmented image
  if (length(dims) == 2) {
    segmented_matrix <- matrix(result$segmentedImage, nrow = dims[1], ncol = dims[2])
  } else if (length(dims) == 3) {
    segmented_matrix <- array(result$segmentedImage, dim = dims)
  }
  
  # Convert to SpatRaster if the input was a SpatRaster
  if (inherits(image, "SpatRaster")) {
    result$segmentedImage <- terra::rast(segmented_matrix)
    crs(result$segmentedImage) <- crs(image)
  } else {
    result$segmentedImage <- segmented_matrix
  }
  
  # Reshape the label image
  result$labelImage <- matrix(result$labelImage, nrow = dims[1], ncol = dims[2])
  
  return(result)
}

rast <- terra::rast("example.jpg")
result <- segment(rast)
segmented_image <- result$segmentedImage

plotRGB(rast)
plotRGB(segmented_image)

