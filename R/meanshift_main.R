#' Segment an image using Mean Shift algorithm
#'
#' @param image Input image (2-D or 3-D array).
#' @param spatial_radius Spatial radius of the search window (integer).
#' @param range_radius Range radius of the search window (double).
#' @param min_density The minimum point density of a region in the segmented image (integer).
#' @param speedup_level Filtering optimization level for fast execution (default: high).
#'
#' @return A list containing:
#'   \item{segmented}{Image where the color of the regions is the mean value of the pixels belonging to a region.}
#'   \item{labels}{2-D array where a pixel value corresponds to the region number the pixel belongs to.}
#'   \item{nb_regions}{The number of regions found by the mean shift algorithm.}
#'
#' @export
segment <- function(image, spatial_radius, range_radius, min_density, speedup_level = SPEEDUP_HIGH) {
  # Convert image to matrix if it's a 3D array
  if (length(dim(image)) == 3) {
    image <- matrix(image, nrow = nrow(image) * ncol(image), ncol = 3)
  }
  
  result <- segment(image, spatial_radius, range_radius, min_density, speedup_level)
  
  # Convert segmented image back to 3D array if necessary
  if (ncol(result$segmented) == 3) {
    result$segmented <- array(result$segmented, dim = c(nrow(image), ncol(image) / 3, 3))
  }
  
  return(result)
}
