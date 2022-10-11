for (j in 1:10) {
  
  directory = paste0("test_runs/test_run", j)
  
  setwd(directory)
  
  source("jkovach2_mymain_9pm.R")
  source("accuracy_evaluation.R")
  
  setwd("../..")
}