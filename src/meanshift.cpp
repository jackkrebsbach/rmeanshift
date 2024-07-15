#include "core/msImageProcessor.h"
#include <Rcpp.h>

using namespace Rcpp;

// [[Rcpp::export]]
List meanshift(NumericVector array, int radiusS, double radiusR,
               unsigned int minDensity, unsigned int speedUp = 2) {
  // Input validation
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

  IntegerVector dim = array.attr("dim");
  int nbDimensions = dim.size();

  if (nbDimensions != 2 && nbDimensions != 3) {
    stop("Array must be 2 dimensional (gray scale image) or 3 dimensional (RGB "
         "color image)");
  }

  int height = dim[0];
  int width = dim[1];
  int channels = (nbDimensions == 3) ? dim[2] : 1;

  msImageProcessor imageSegmenter;
  SpeedUpLevel speedUpLevel;

  // Convert NumericVector to unsigned char*
  std::vector<unsigned char> imageData(height * width * channels);
  for (int i = 0; i < height * width * channels; ++i) {
    imageData[i] = static_cast<unsigned char>(
        std::max(0, std::min(255, static_cast<int>(array[i]))));
  }

  // Define the image
  if (nbDimensions == 2) {
    imageSegmenter.DefineImage(imageData.data(), GRAYSCALE, height, width);
  } else {
    imageSegmenter.DefineImage(imageData.data(), COLOR, height, width);
  }

  // Set speedup level
  switch (speedUp) {
  case 0:
    speedUpLevel = NO_SPEEDUP;
    break;
  case 1:
    speedUpLevel = MED_SPEEDUP;
    break;
  case 2:
  default:
    speedUpLevel = HIGH_SPEEDUP;
  }

  // Segment image
  imageSegmenter.Segment(radiusS, radiusR, minDensity, speedUpLevel);

  // Get segmented image
  NumericVector segmentedImage(height * width * channels);
  std::vector<unsigned char> segmentedData(height * width * channels);
  imageSegmenter.GetResults(segmentedData.data());
  for (int i = 0; i < height * width * channels; ++i) {
    segmentedImage[i] = static_cast<double>(segmentedData[i]);
  }
  segmentedImage.attr("dim") = dim;

  // Get labels and number of regions
  IntegerMatrix labelImage(height, width);
  int *tmpLabels;
  float *tmpModes;
  int *tmpModePointCounts;
  int nbRegions =
      imageSegmenter.GetRegions(&tmpLabels, &tmpModes, &tmpModePointCounts);

  // Copy label data
  std::copy(tmpLabels, tmpLabels + height * width, labelImage.begin());

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
