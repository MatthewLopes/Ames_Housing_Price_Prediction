file_1 = "jkovach2_mymain_9pm.R"
file_2 = "accuracy_evaluation.R"

for (j in 1:10) {
  
 directory = paste0("test_runs/test_run", j)
 file.copy(file_1, directory)
 file.copy(file_2, directory)
 
 setwd(directory)
 source(file_1)
 source(file_2)
  
  
  setwd("../..")
}