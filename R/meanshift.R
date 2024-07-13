#' @useDynLib rmeanshift, .registration = TRUE
#' @importFrom Rcpp evalCpp
#' @import methods
NULL

#' @export
SPEEDUP_NO <- 0L
#' @export
SPEEDUP_MEDIUM <- 1L
#' @export
SPEEDUP_HIGH <- 2L

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
  
  result <- .Call('_rmeanshift_segment', PACKAGE = 'rmeanshift',
                  image, spatial_radius, range_radius, min_density, speedup_level)
  
  # Convert segmented image back to 3D array if necessary
  if (ncol(result$segmented) == 3) {
    result$segmented <- array(result$segmented, dim = c(nrow(image), ncol(image) / 3, 3))
  }
  
  return(result)
}

#' Segmenter class using the mean shift algorithm to segment images
#'
#' @export
Segmenter <- setRefClass("Segmenter",
  fields = list(
    spatial_radius = "numeric",
    range_radius = "numeric",
    min_density = "numeric",
    speedup_level = "integer"
  ),
  methods = list(
    initialize = function(spatial_radius = NULL, range_radius = NULL, min_density = NULL, speedup_level = SPEEDUP_HIGH) {
      if (!is.null(spatial_radius)) .self$spatial_radius <- spatial_radius
      if (!is.null(range_radius)) .self$range_radius <- range_radius
      if (!is.null(min_density)) .self$min_density <- min_density
      .self$speedup_level <- speedup_level
    },
    segment = function(image) {
      "Segment the input image (color or grayscale)."
      if (is.null(.self$spatial_radius)) stop("Spatial radius has not been set")
      if (is.null(.self$range_radius)) stop("Range radius has not been set")
      if (is.null(.self$min_density)) stop("Minimum density has not been set")
      
      segment(image, .self$spatial_radius, .self$range_radius, .self$min_density, .self$speedup_level)
    },
    show = function() {
      cat("<Segmenter: ",
          "spatial_radius=", .self$spatial_radius,
          ", range_radius=", .self$range_radius,
          ", min_density=", .self$min_density,
          ", speedup_level=", .self$speedup_level,
          ">\n", sep = "")
    }
  )
)

# Setter methods with validation
Segmenter$methods(
  set_spatial_radius = function(value) {
    if (value < 0) stop("Spatial radius must be greater or equal to zero")
    .self$spatial_radius <- value
  },
  set_range_radius = function(value) {
    if (value < 0) stop("Range radius must be greater or equal to zero")
    .self$range_radius <- value
  },
  set_min_density = function(value) {
    if (value < 0) stop("Minimum density must be greater or equal to zero")
    .self$min_density <- value
  },
  set_speedup_level = function(value) {
    if (!(value %in% c(SPEEDUP_NO, SPEEDUP_MEDIUM, SPEEDUP_HIGH))) {
      stop("Speedup level must be 0 (no speedup), 1 (medium speedup), or 2 (high speedup)")
    }
    .self$speedup_level <- as.integer(value)
  }
)
