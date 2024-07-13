rm(list = ls())
gc()
library(devtools)
library(terra)


devtools::clean_dll()
devtools::document(roclets = c('rd', 'collate', 'namespace'))
Rcpp::compileAttributes()
devtools::load_all()


img <- terra::rast('/Users/krebsbach/Downloads/Pymeanshift example.jpg')
plotRGB(img)


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
  result$dims <- dims  # Add the dimensions to the result
  return(result)
}

rast <- terra::rast("/Users/krebsbach/Downloads/Pymeanshift example.jpg")
result <- segment(rast)

# Extract the segmented image, label image, number of regions, and dimensions
segmented_image <- result$segmentedImage
label_image <- result$labelImage
nb_regions <- result$nbRegions
dims <- result$dims  # Get the dimensions from the result

# Convert the segmented image back to a matrix or array
if (length(dims) == 2) {
  segmented_matrix <- matrix(segmented_image, nrow = dims[1], ncol = dims[2], byrow = TRUE)
} else if (length(dims) == 3) {
  segmented_matrix <- array(segmented_image, dim = dims)
}

# Create a SpatRaster from the matrix or array
segmented_raster <- rast(segmented_matrix)

# Plot the segmented raster
plotRGB(segmented_raster)

