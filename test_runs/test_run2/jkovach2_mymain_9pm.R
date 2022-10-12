list.of.packages <- c("caret", "xgboost", "randomForest", "glmnet")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

library(caret)
library(xgboost)
library(randomForest)
library(glmnet)

set.seed(1852)

# Get data
train <- read.csv("train.csv")
test <- read.csv("test.csv")
PIDs <- test[,1]

drop <- c('Street', 'Utilities', 'Condition_2', 'Roof_Matl', 'Heating', 'Pool_QC', 'Misc_Feature', 'Low_Qual_Fin_SF', 'Pool_Area', 'Longitude','Latitude')
train = train[,!(names(train) %in% drop)]
test = test[,!(names(test) %in% drop)]

train[is.na(train)] = 0
test[is.na(test)] = 0

# Preprocessing
x_train_drop <- c('PID','Sale_Price')
train.x  = train[,!(names(train) %in% x_train_drop)] # train data without "PID" and "Sale_Price"
train.y = log(train['Sale_Price'])# log transformed "Sale_Price"

# Process train data
categorical.vars <- colnames(train.x)[
  which(sapply(train.x,
               function(x) mode(x)=="character"))]
train.matrix <- train.x[, !colnames(train.x) %in% categorical.vars, 
                        drop=FALSE]
n.train <- nrow(train.matrix)

train_levels <- list()

#Save train.x levels to compare with test.x levels later
for(var in categorical.vars){
  mylevels <- sort(unique(train.x[, var]))
  train_levels <- c(train_levels, mylevels)
  m <- length(mylevels)
  m <- ifelse(m>2, m, 1)
  tmp.train <- matrix(0, n.train, m)
  col.names <- NULL
  for(j in 1:m){
    tmp.train[train.x[, var]==mylevels[j], j] <- 1
    col.names <- c(col.names, paste(var, '_', mylevels[j], sep=''))
  }
  colnames(tmp.train) <- col.names
  train.matrix <- cbind(train.matrix, tmp.train)
}

# Process test data
x_test_drop <- 'PID'
test.x = test[,!(names(test) %in% x_test_drop)] # test data without "PID" and "Sale_Price"

test_categorical.vars <- colnames(test.x)[
  which(sapply(test.x, function(x) mode(x)=="character"))]

test.matrix <- test.x[, !colnames(test.x) %in% test_categorical.vars, 
                      drop=FALSE]
n.test <- nrow(test.matrix)

for(var in categorical.vars){
  testlevels <- sort(unique(test.x[, var]))
  m <- length(testlevels)
  m <- ifelse(m>2, m, 1)
  tmp.test <- matrix(0, n.test, m)
  col.names <- NULL
  for(j in 1:m){
    tmp.test[test.x[, var]==testlevels[j], j] <- 1
    col.names <- c(col.names, paste(var, '_', testlevels[j], sep=''))
  }
  colnames(tmp.test) <- col.names
  test.matrix <- cbind(test.matrix, tmp.test)
}

# We need to match the columns for train.matrix to test.matrix. 
# If there is a column in train.matrix that isnt in test.matrix create the column with all 0 values in the test.matrix. 
# If there is a column in test.matrix that is not in train.matrix remove that column from test.matrix. 
# Columns have to be the same order for both

test_col_names = colnames(test.matrix)
train_col_names = colnames(train.matrix)

columns_to_drop_from_test_matrix = c()

for (test_name in test_col_names) {
  found = 0
  
  for (train_name in train_col_names) {
    if(train_name == test_name) {
      found = 1
    }
  }
  
  if(found == 0) {
    columns_to_drop_from_test_matrix = c(columns_to_drop_from_test_matrix, test_name)
  }
}

test.matrix = test.matrix[,!(names(test.matrix) %in% columns_to_drop_from_test_matrix)]

test_matrix_df = as.data.frame(test.matrix)
train_matrix_df = as.data.frame(train.matrix)


for (train_name in train_col_names) {
  found = 0
  
  for (test_name in test_col_names) {
    if(test_name == train_name) {
      found = 1
    }
  }
  
  if(found == 0) {
    test_matrix_df[train_name] = rep(0, dim(test.matrix)[1])
  }
}

test_matrix_df = test_matrix_df[,sort(names(test_matrix_df))]
train_matrix_df = train_matrix_df[,sort(names(train_matrix_df))]

# Remember to set a seed so we can reproduce your results; 
# the seed does not need to be related to your UIN. 



# Decision Tree
xgb.model <- xgboost(data = as.matrix(train_matrix_df), 
                     label = as.matrix(train.y), max_depth = 6,
                     eta = 0.05, nrounds = 5000,
                     subsample = 0.5,
                     verbose = FALSE)

df = data.frame(PID = PIDs, Sale_Price = exp(predict(xgb.model, as.matrix(test_matrix_df))))

write.csv(df,"mysubmission1.txt", row.names = FALSE, quote=FALSE)



# Lasso regression
mylasso.lambda.seq = exp(seq(-10, 1, length.out = 100))
cv.out = cv.glmnet(as.matrix(train_matrix_df), as.matrix(train.y), alpha = 0.77, 
                   lambda = mylasso.lambda.seq)

best.lam = cv.out$lambda.min
Ytest.pred = exp(predict(cv.out, s = best.lam, newx = as.matrix(test_matrix_df)))
colnames(Ytest.pred)[1]<-"Sale_Price"
ridge_df = data.frame(PID =  PIDs, Sale_Price = Ytest.pred)
write.csv(ridge_df,"mysubmission2.txt", row.names = FALSE, quote=FALSE)

