#' Mean Shift Segmentation on Raster or Array Images
#'
#' Performs mean shift segmentation on multi-channel images.
#' Input can be a `terra::rast` or a 3D array [height, width, channels].
#'
#' @param img A `terra::rast` object or 3D array [height, width, channels].
#' @param radiusS Numeric scalar. Spatial bandwidth. Default 5.
#' @param radiusR Numeric scalar. Range/color bandwidth. Default 4.5.
#' @param minDensity Integer. Minimum density for clusters. Default 200.
#' @param speedUp Integer. Optional speed-up level. Default 2.
#'
#' @return If input is `terra::rast`, returns segmented raster; if array, returns 3D array.
#' @export
meanshift <- function(img, radiusS = 5, radiusR = 4.5, minDensity = 200, speedUp = 2) {

  if (inherits(img, "SpatRaster")) {
    height <- dim(img)[1]
    width <- dim(img)[2]
    channels <- dim(img)[3]
    img_arr <- terra::as.array(img)
  } else if (is.array(img) && length(dim(img)) == 3) {
    height <- dim(img)[1]
    width <- dim(img)[2]
    channels <- dim(img)[3]
    img_arr <- img
  } else {
    stop("Input must be a terra::rast or a 3D array [height, width, channels].")
  }

  img_arr <- img_arr[height:1, , , drop = FALSE]
  img_arr <- aperm(img_arr, c(3,2,1))
  image_flat <- as.vector(img_arr)

  result <- rmeanshift::meanshift_(image_flat, width, height, channels, radiusS, radiusR, minDensity, speedUp)

  result_arr <- array(result, dim = c(channels, width, height))
  result_arr <- aperm(result_arr, c(3,2,1))

  if (inherits(img, "SpatRaster")) {
    result_rast <- terra::rast(result_arr)
    terra::ext(result_rast) <- terra::ext(img)
    terra::crs(result_rast) <- terra::crs(img)
    return(result_rast)
  } else {
    return(result_arr)
  }
}
