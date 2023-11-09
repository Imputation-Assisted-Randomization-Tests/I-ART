devtools::install_github("Imputation-Assisted-Randomization-Tests/R-I-ART")
library(I-ART)
Z <- c(1, 1, 1, 1, 0, 0, 0, 0)
X <- matrix(c(5.1, 3.5, 4.9, NA, 4.7, 3.2, 4.5, NA, 7.2, 2.3, 8.6, 3.1, 6.0, 3.6, 8.4, 3.9), ncol = 2)
Y <- matrix(c(4.4, 0.5, 4.3, 0.7, 4.1, NA, 5.0, 0.4, 1.7, 0.1, NA, 0.2, 1.4, NA, 1.7, 0.4), ncol = 2)
print(iartest.iartest(Z, X, Y, L = 1000, verbose = TRUE))



