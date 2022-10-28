# project_1

Project 1: Predict the Housing Prices in Ames
Fall 2022
Ames Housing Data
Data set
Download [Ames_data.csv]. This dataset has 2930 rows (i.e., houses) and 83 columns.

The first column is “PID”, the Parcel identification number;
The last column is the response variable, Sale_Price;
The remaining 81 columns are explanatory variables describing (almost) every aspect of residential homes.
Test IDs
Download [project1_testIDs.dat]. This file contains 879 rows and 10 columns, which will be used to generate 10 sets of training/test splits from Ames_data.csv. Each column contains the 879 row-numbers of a test data.

Here is how you generate a split of training and test using the j-th column of project1_testIDs.dat in R.

data <- read.csv("Ames_data.csv")
testIDs <- read.table("project1_testIDs.dat")
j <- 2
train <- data[-testIDs[,j], ]
test <- data[testIDs[,j], ]
test.y <- test[, c(1, 83)]
test <- test[, -83]
write.csv(train,"train.csv",row.names=FALSE)
write.csv(test, "test.csv",row.names=FALSE)
write.csv(test.y,"test_y.csv",row.names=FALSE)
Save the training and test as csv files. In particular, the test data are saved as two separate files: one containing just the feature vectors and the other one containing the response column. For your remaining analysis, you need to read the training and test data from those csv files.

Goal
The goal is to predict the price of a home (in log scale) with those explanatory variables. You need to build TWO prediction models selected from the following two categories:

one based on linear regression models with Lasso or Ridge or Elasticnet penalty;
one based on tree models, such as randomForest or boosting tree.
Features used for these two models do not need to be the same. Please check Campuswire for packages students are allowed to use for this project.
