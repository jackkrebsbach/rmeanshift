#include "core/msImageProcessor.h"
#include <Rcpp.h>
#include <vector>

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
  Rcout << "Dimensions: " << nbDimensions << std::endl;
  Rcout << "Dim 0: " << dim[0] << " Dim 1: " << dim[1];
  if (nbDimensions == 3) {
    Rcout << " Dim 2: " << dim[2];
  }
  Rcout << std::endl;

  if (nbDimensions != 2 && nbDimensions != 3) {
    stop("Array must be 2-dimensional (gray scale image) or 3-dimensional (RGB "
         "color image)");
  }

  msImageProcessor imageSegmenter;
  SpeedUpLevel speedUpLevel = static_cast<SpeedUpLevel>(speedUp);

  // Define the image based on its dimensions
  if (nbDimensions == 2) {
    // Grayscale image
    Rcout << "Defining image as GRAYSCALE with dimensions: " << dim[0] << "x"
          << dim[1] << std::endl;
    imageSegmenter.DefineImage((unsigned char *)array.begin(), GRAYSCALE,
                               dim[0], dim[1]);
  } else if (nbDimensions == 3 && dim[2] == 3) {
    // RGB image
    Rcout << "Defining image as COLOR (RGB) with dimensions: " << dim[0] << "x"
          << dim[1] << std::endl;

    // Ensure the data is correctly ordered for the DefineImage function
    int totalSize = dim[0] * dim[1] * dim[2];
    std::vector<unsigned char> imageData(totalSize);
    for (int i = 0; i < totalSize; ++i) {
      imageData[i] = static_cast<unsigned char>(
          array[i] & 0xFF); // Ensure data is within unsigned char range
    }

    imageSegmenter.DefineImage(imageData.data(), COLOR, dim[0], dim[1]);
  } else {
    stop("Unsupported dimensions for the image.");
  }

  // Create output images
  // The segmented image should have the same size as the input image
  int totalSize = dim[0] * dim[1] * (nbDimensions == 3 ? dim[2] : 1);
  std::vector<unsigned char> segmentedImage(totalSize);
  IntegerVector labelImage(dim[0] * dim[1]);

  // Segment the image
  imageSegmenter.Segment(radiusS, radiusR, minDensity, speedUpLevel);
  imageSegmenter.GetResults(segmentedImage.data());

  // Log the results
  Rcout << "Segmented Image (first few values):" << std::endl;
  for (int i = 0; i < 100 && i < totalSize; ++i) {
    Rcout << (int)segmentedImage[i] << " ";
  }
  Rcout << std::endl;

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

  // Convert segmented image back to IntegerVector
  IntegerVector segmentedImageInt(totalSize);
  for (int i = 0; i < totalSize; ++i) {
    segmentedImageInt[i] = segmentedImage[i];
  }

  // Return a list with the segmented image, the label image, and the number of
  // regions
  return List::create(Named("segmentedImage") = segmentedImageInt,
                      Named("labelImage") = labelImage,
                      Named("nbRegions") = nbRegions);
}
