#include "core/msImageProcessor.h"
#include <Rcpp.h>

using namespace Rcpp;

// [[Rcpp::export]]
List meanshift(IntegerVector array, IntegerVector dim, int radiusS,
               double radiusR, unsigned int minDensity,
               unsigned int speedUp = 2) {
  // Check input arguments
  if (radiusS < 0) {
    stop("Spatial radius must be greater or equal to zero");
  }

  if (radiusR < 0.0) {
    stop("Range radius must be greater or equal to zero");
  }

  if (minDensity < 0) {
    stop("Minimum density must be greater or equal to zero");
  }

  if (speedUp > 2) {
    stop("Speedup level must be 0 (no speedup), 1 (medium speedup), or 2 (high "
         "speedup)");
  }

  int nbDimensions = dim.size();

  if (nbDimensions != 2 && nbDimensions != 3) {
    stop("Array must be 2-dimensional (gray scale image) or 3-dimensional (RGB "
         "color image)");
  }

  msImageProcessor imageSegmenter;
  SpeedUpLevel speedUpLevel = static_cast<SpeedUpLevel>(speedUp);

  // Define the image based on its dimensions
  if (nbDimensions == 2) {
    imageSegmenter.DefineImage((unsigned char *)array.begin(), GRAYSCALE,
                               dim[0], dim[1]);
  } else if (nbDimensions == 3 && dim[2] == 3) {
    imageSegmenter.DefineImage((unsigned char *)array.begin(), COLOR, dim[0],
                               dim[1]);
  } else {
    stop("Unsupported dimensions for the image.");
  }

  // Create output images
  // The segmented image should have the same size as the input image
  int totalSize = array.size();
  IntegerVector segmentedImage(totalSize);
  IntegerVector labelImage(dim[0] * dim[1]);

  // Segment the image
  imageSegmenter.Segment(radiusS, radiusR, minDensity, speedUpLevel);
  imageSegmenter.GetResults((unsigned char *)segmentedImage.begin());

  // Get labels and number of regions
  int *tmpLabels;
  float *tmpModes;
  int *tmpModePointCounts;
  int nbRegions =
      imageSegmenter.GetRegions(&tmpLabels, &tmpModes, &tmpModePointCounts);
  std::copy(tmpLabels, tmpLabels + dim[0] * dim[1], labelImage.begin());

  // Clean up
  delete[] tmpLabels;
  delete[] tmpModes;
  delete[] tmpModePointCounts;

  // Return a list with the segmented image, the label image, and the number of
  // regions
  return List::create(Named("segmentedImage") = segmentedImage,
                      Named("labelImage") = labelImage,
                      Named("nbRegions") = nbRegions);
}
