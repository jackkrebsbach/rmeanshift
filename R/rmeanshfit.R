#' Mean Shift Segmentation image data
#'
#' Performs mean shift segmentation on multi-channel images.
#' Input can be a 3D array [height, width, channels]
#'
#' @param img A 3D array [height, width, channels] representing a color image
#' @param radiusS Numeric scalar. Spatial bandwidth. Default 5.
#' @param radiusR Numeric scalar. Range/color bandwidth. Default 4.5.
#' @param minDensity Integer. Minimum density for clusters. Default 200.
#' @param speedUp Integer. Optional speed-up level. Default 2.
#' @param scale Boolean. Scales image values to 0-255. Default TRUE
#'
#' @return Returns an array of the same shape as the input
#' @export
meanshift <- function(img, radiusS = 5, radiusR = 4.5, minDensity = 200, speedUp = 2, scale = TRUE) {

  if(!length(dim(img_array)) == 3){
    warning("Input must be a 3D array with the last dimension representing the number of channels.")
  }

  height <- dim(img)[1]
  width <- dim(img)[2]
  channels <- dim(img)[3]

  img <- img[height:1, , , drop = FALSE]
  img <- aperm(img, c(3,2,1))

  # Core segmentation code requires values scaled between 0-255
  if(scale){
    for (i in 1:dim(img)[1]) {
      band_min <- min(img[i, , ])
      band_max <- max(img[i, , ])
      img[i, , ] <- (img[i, , ] - band_min) / (band_max - band_min) * 255
    }
  }

  image_flat <- as.vector(img)

  result <- rmeanshift::meanshift_(image_flat, width, height, channels, radiusS, radiusR, minDensity, speedUp)

  result <- array(result, dim = c(channels, width, height))
  result <- aperm(result, c(3,2,1))

  return(result)

}
