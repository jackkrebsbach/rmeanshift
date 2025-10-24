# Meanshift: a robust approach toward feature space analysis.

This package provides an R interface to the Mean Shift algorithm implemented in C++ by D. Comaniciu and P. Meer.

| Original                 | Segmented                           |
|--------------------------|-------------------------------------|
| ![Original](example.jpg) | ![Segmented](example_segmented.jpg) |

The original paper can be found at: <https://ieeexplore.ieee.org/document/1000236/>

The original C++ code can be found at: <https://cecas.clemson.edu/~stb/blepo/>

## Example

``` r
library(devtools)
library(terra)
library(Rcpp)

if (!requireNamespace("rmeanshift", quietly = TRUE)) {
 devtools::install_github("jackkrebsbach/rmeanshift")
}

library(rmeanshift)

img <- terra::rast("example.jpg")

result <- rmeanshift::meanshift(img, radiusS =  5, radiusR = 4.5, minDensity =  200)

terra::plotRGB(result)
```
