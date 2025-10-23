#include "core/msImageProcessor.h"
#include "core/tdef.h"
#include <Rcpp.h>
#include <vector>

using namespace Rcpp;

// [[Rcpp::export]]
NumericVector meanshift_(NumericVector array, int width, int height, int channels,
                        int radiusS, double radiusR, unsigned int minDensity, unsigned int speedUp = 2) {

  unsigned char* imageData = new unsigned char[height * width * channels];
  for (int i = 0; i < height * width * channels; ++i) {
    double val = array[i];
    imageData[i] = static_cast<unsigned char>(val);
  }

  msImageProcessor imageSegmenter;
  SpeedUpLevel speedUpLevel;

  imageSegmenter.DefineImage(imageData, COLOR, height, width);
  imageSegmenter.Segment(radiusS, radiusR, minDensity, NO_SPEEDUP);

  unsigned char* segmentedData = new unsigned char[height * width * channels];
  imageSegmenter.GetResults(segmentedData);

  NumericVector result(height * width * channels);
  for (int i = 0; i < height * width * channels; ++i) {
    result[i] = static_cast<double>(segmentedData[i]);
  }

  delete[] imageData;
  delete[] segmentedData;

  return result;
}
