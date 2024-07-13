#include "core/msImageProcessor.h"
#include <Rcpp.h>

// [[Rcpp::export]]
Rcpp::List segment(Rcpp::NumericMatrix image, int spatialRadius,
                   double rangeRadius, int minDensity, int speedUp = 2) {
  // Input validation
  if (spatialRadius < 0) {
    Rcpp::stop("Spatial radius must be greater or equal to zero");
  }
  if (rangeRadius < 0.) {
    Rcpp::stop("Range radius must be greater or equal to zero");
  }
  if (minDensity < 0) {
    Rcpp::stop("Minimum density must be greater or equal to zero");
  }
  if (speedUp < 0 || speedUp > 2) {
    Rcpp::stop("Speedup level must be 0 (no speedup), 1 (medium speedup), or 2 "
               "(high speedup)");
  }

  msImageProcessor imageSegmenter;
  SpeedUpLevel speedUpLevel;

  // Set speedup level
  switch (speedUp) {
  case 0:
    speedUpLevel = NO_SPEEDUP;
    break;
  case 1:
    speedUpLevel = MED_SPEEDUP;
    break;
  case 2:
    speedUpLevel = HIGH_SPEEDUP;
    break;
  default:
    speedUpLevel = HIGH_SPEEDUP;
  }

  // Determine if the image is grayscale or color
  bool isColor = (image.ncol() == 3);
  int width = image.nrow();
  int height = isColor ? image.ncol() / 3 : image.ncol();

  // Convert R matrix to unsigned char array
  std::vector<unsigned char> inputImage(width * height * (isColor ? 3 : 1));
  for (int i = 0; i < inputImage.size(); ++i) {
    inputImage[i] =
        static_cast<unsigned char>(std::max(0.0, std::min(255.0, image[i])));
  }

  // Define and segment the image
  imageSegmenter.DefineImage(inputImage.data(), isColor ? COLOR : GRAYSCALE,
                             height, width);
  imageSegmenter.Segment(spatialRadius, rangeRadius, minDensity, speedUpLevel);

  // Get segmented image
  Rcpp::NumericMatrix segmentedImage(width, height * (isColor ? 3 : 1));
  imageSegmenter.GetResults(
      reinterpret_cast<unsigned char *>(segmentedImage.begin()));

  // Get labels and number of regions
  int *tmpLabels;
  float *tmpModes;
  int *tmpModePointCounts;
  int nbRegions =
      imageSegmenter.GetRegions(&tmpLabels, &tmpModes, &tmpModePointCounts);

  Rcpp::IntegerMatrix labelImage(width, height);
  std::memcpy(labelImage.begin(), tmpLabels, width * height * sizeof(int));

  // No need to delete tmpLabels, tmpModes, tmpModePointCounts as they are
  // managed by msImageProcessor

  return Rcpp::List::create(Rcpp::Named("segmented") = segmentedImage,
                            Rcpp::Named("labels") = labelImage,
                            Rcpp::Named("nb_regions") = nbRegions);
}
