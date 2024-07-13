test_that("meanshift function works", {
  # Create a simple test image
  test_image <- matrix(runif(100*100*3), nrow=100, ncol=300)
  
  # Run meanshift
  result <- segment(test_image, spatialRadius = 5, rangeRadius = 5, minDensity = 50)
  
  # Check that the result has the expected structure
  expect_type(result, "list")
  expect_named(result, c("segmented", "labels", "nb_regions"))
  expect_equal(dim(result$segmented), dim(test_image))
  expect_equal(dim(result$labels), c(100, 100))
  expect_type(result$nb_regions, "integer")
})
