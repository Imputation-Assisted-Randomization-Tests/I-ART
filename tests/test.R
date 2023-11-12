devtools::install_github("Imputation-Assisted-Randomization-Tests/iArt", force = TRUE)

library(iArt)
Z <- c(1, 1, 1, 1, 0, 0, 0, 0)
X <- matrix(c(5.1, 3.5, 4.9, NA, 4.7, 3.2, 4.5, NA, 7.2, 2.3, 8.6, 3.1, 6.0, 3.6, 8.4, 3.9), ncol = 2)
Y <- matrix(c(4.4, 4.3, 4.1, 5.0, 1.7, NA, 1.4, 1.7,0.5, 0.7, NA, 0.4, 0.1, 0.2, NA, 0.4), ncol = 2, byrow = TRUE)
result <- iArt.test(Z = Z, X = X, Y = Y, L = 100, verbose = TRUE)

print(result)

Z <- c(1, 1, 1, 1, 0, 0, 0, 0)
X <- matrix(c(5.1, 3.5, 4.9, 4.0, 4.7, 3.2, 4.5, 5, 7.2, 2.3, 8.6, 3.1, 6.0, 3.6, 8.4, 3.9), ncol = 2)
Y <- matrix(c(4.4, 4.3, NA, 5.0, 1.1, NA, 1.4, 1.7), ncol = 1, byrow = TRUE)
result <- iArt.test(Z = Z, X = X, Y = Y, L = 100,covariate_adjustment = TRUE, verbose = TRUE)

print(result)