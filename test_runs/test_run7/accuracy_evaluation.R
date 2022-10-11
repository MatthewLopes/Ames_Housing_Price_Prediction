test.y <- read.csv("test_y.csv")

pred <- read.csv("mysubmission1.txt")
names(test.y)[2] <- "True_Sale_Price"
pred <- merge(pred, test.y, by="PID")
print(sqrt(mean((log(pred$Sale_Price) - log(pred$True_Sale_Price))^2)))


pred <- read.csv("mysubmission2.txt")
names(test.y)[2] <- "True_Sale_Price"
pred <- merge(pred, test.y, by="PID")
print(sqrt(mean((log(pred$Sale_Price) - log(pred$True_Sale_Price))^2)))