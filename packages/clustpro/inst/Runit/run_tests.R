library('RUnit')

source('R/clustpro.R')

test.suite <- defineTestSuite("example",
                              dirs = file.path("inst/Runit"),
                              testFileRegexp = '^unitTest_.*\\.R')

test.result <- runTestSuite(test.suite)

printTextProtocol(test.result)
