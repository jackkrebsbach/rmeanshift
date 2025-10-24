test_that("meanshift function works", {
  # Create a simple test image
  test_image <- matrix(runif(100*100*3), nrow=100, ncol=300)
  
  # Run meanshift
  result <- meanshift(test_image, radiusS = 5, radiusR = 5, minDensity = 50)
  
  # Check that the result has the expected structure
  expect_type(result, "list")
  expect_named(result, c("segmentedImage", "labelImage", "nbRegions"))
  expect_equal(dim(result$segmentedImage), dim(test_image))
  expect_type(result$nbRegions, "integer")
})
