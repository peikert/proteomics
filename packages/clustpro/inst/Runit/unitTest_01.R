library("clustpro")

test.examples <- function()
{
  checkEquals(6, factorial(3))
  checkEqualsNumeric(6, factorial(3))
  checkIdentical(6, factorial(3))
  checkTrue(2 + 2 == 4, 'Arithmetic works')
  checkException(log('a'), 'Unable to take the log() of a string')
  source(path.package(package="clustpro"))
  class(get_best_k(iris[,1:4],min_k = 2,max_k = 10, method = 'kmeans', seed = 1234)$db_list)
}

test.deactivation <- function()
{
  DEACTIVATED('Deactivating this test function')
}
