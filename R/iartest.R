# Install the mice package if not already installed
if (!requireNamespace("mice", quietly = TRUE)) {
  install.packages("mice")
}


# Load the mice package
library(mice)

# Install the missForest package if not already installed
if (!requireNamespace("missForest", quietly = TRUE)) {
  install.packages("missForest")
}

# Load the missForest package
library(missForest)

T <- function(z, y) {
  n <- length(z)
  t <- 0
  my_list <- data.frame(z, y)
  sorted_list <- my_list[order(my_list$y),]
  
  for (i in 1:n) {
    t <- t + sorted_list$z[i] * (i + 1)
  }
  
  return(t)
}

getY <- function(G, Z, X, Y, covariate_adjustment = FALSE) {
  # Combine Z, X, Y into a single data frame
  df_Z <- data.frame(cbind(Z, X, Y))
  
  # Impute the missing values in the combined data frame
  imputed_data <- G(df_Z)
  completed_data <- complete(imputed_data, 1)
  
  # Extract imputed Y values
  lenY <- ncol(Y)
  indexY <- ncol(Z) + ncol(X) + 1 # Assuming Z and X are not NULL
  Y_head <- completed_data[, indexY:(indexY + lenY - 1)]
  
  if (covariate_adjustment) {
    # Perform covariate adjustment if required
    # Fit a model (e.g., linear regression) to predict Y_head based on X
    # Then adjust Y_head based on this model
    fit_model <- lm(Y_head ~ X, data = completed_data)
    Y_head_adjusted <- predict(fit_model, newdata = data.frame(X))
    Y_head <- Y_head - Y_head_adjusted
  }
  
  return(Y_head)
}

split_data <- function(y, z, M) {
  # Convert M to a logical vector to identify missing values
  missing_indices <- as.logical(M)

  non_missing_indices <- !missing_indices

  # Split y based on missing and non-missing indices
  y_missing <- y[missing_indices, ]
  y_non_missing <- y[non_missing_indices, ]

  # Split z in the same way
  z_missing <- z[missing_indices, ]
  z_non_missing <- z[non_missing_indices, ]

  return(list(y_missing = y_missing, y_non_missing = y_non_missing, 
              z_missing = z_missing, z_non_missing = z_non_missing))
}


getT <- function(y, z, lenY, M) {
  t <- numeric(lenY)
  
  for (i in 1:lenY) {
    # Split the data into missing and non-missing parts
    split_result <- split_data(y[, i, drop = FALSE], z, M[, i, drop = FALSE])
    
    # Calculate T for missing and non-missing parts
    t_missing <- if (length(split_result$y_missing) > 0 && length(split_result$z_missing) > 0) {
      T(split_result$z_missing, split_result$y_missing)
    } else {
      0
    }
    
    t_non_missing <- if (length(split_result$y_non_missing) > 0 && length(split_result$z_non_missing) > 0) {
      T(split_result$z_non_missing, split_result$y_non_missing)
    } else {
      0
    }
    
    # Sum the T values for both parts
    t[i] <- t_missing + t_non_missing
  }
  
  return(t)
}

getZsimTemplates <- function(Z_sorted, S) {
  Z_sim_templates <- list()
  
  unique_strata <- unique(S)
  
  for (stratum in unique_strata) {
    strata_indices <- which(S == stratum)
    strata_Z <- Z_sorted[strata_indices]
    p <- mean(strata_Z)
    strata_size <- length(strata_indices)
    
    # Create a template for the stratum
    Z_sim_template <- c(rep(0.0, strata_size * (1 - p)), rep(1.0, strata_size * p))
    
    Z_sim_templates[[as.character(stratum)]] <- Z_sim_template
  }
  
  return(Z_sim_templates)
}

getZsim <- function(Z_sim_templates) {
  Z_sim <- numeric()
  
  for (Z_sim_template in Z_sim_templates) {
    # Shuffle the current template
    strata_Z_sim <- sample(Z_sim_template)
    
    # Append the shuffled template to Z_sim
    Z_sim <- c(Z_sim, strata_Z_sim)
  }
  
  return(Z_sim)
}

check_param <- function(Z, X, Y, S, G, L, verbose, covariate_adjustment, alpha, alternative, random_state) {
  
  # Check if Z, X, Y are matrices or data frames
  if (!is.matrix(X) && !is.data.frame(X)) stop("X must be a matrix or data frame")
  if (!is.matrix(Y) && !is.data.frame(Y)) stop("Y must be a matrix or data frame")
  
  # Check Z: must contain only 0, 1
  if (!all(Z %in% c(0, 1))) stop("Z must contain only 0, 1")
  
  # Check X and Y: must be 2D structures
  if (ncol(X) < 1) stop("X must have at least one column")
  if (ncol(Y) < 1) stop("Y must have at least one column")
  
  # Check S: if provided, must be a vector or 1D matrix
  if (!is.null(S) && !is.vector(S) && !(is.matrix(S) && ncol(S) == 1)) stop("S must be a vector or a single column matrix")
  
  # Check L: must be a positive integer
  if (!is.numeric(L) || L <= 0 || L != as.integer(L)) stop("L must be a positive integer")
  
  # Check verbose: must be TRUE or FALSE
  if (!is.logical(verbose)) stop("verbose must be TRUE or FALSE")
  
  # Check alpha: must be between 0 and 1
  if (!is.numeric(alpha) || alpha <= 0 || alpha > 1) stop("alpha must be between 0 and 1")
  
  # Check G: must not be NULL
  if (is.null(G)) stop("G cannot be NULL")
  
  # Check covariate_adjustment: must be TRUE or FALSE
  if (!is.logical(covariate_adjustment)) stop("covariate_adjustment must be TRUE or FALSE")
  
  # Check alternative: must be "one-sided" or "two-sided"
  if (!alternative %in% c("one-sided", "two-sided")) stop("alternative must be 'one-sided' or 'two-sided'")
  
  # Check random_state: if provided, must be a positive integer or NULL
  if (!is.null(random_state) && (!is.numeric(random_state) || random_state <= 0 || random_state != as.integer(random_state))) {
    stop("random_state must be a positive integer or NULL")
  }
}

choosemodel <- function(G) {
  G <- tolower(G) # Convert G to lowercase
  
  if (G == "missforest") {
    # Return missForest imputer function
    return(function(data) missForest::missForest(data,printFlag = FALSE))
  } else if (G == "median") {
    # Return simple imputer for median
    return(function(data) apply(data, 2, function(col) ifelse(is.na(col), median(col, na.rm = TRUE), col)))
  } else if (G == "mean") {
    # Return simple imputer for mean
    return(function(data) apply(data, 2, function(col) ifelse(is.na(col), mean(col, na.rm = TRUE), col)))
  } else if (G == "mice") {
    # Return MICE imputer function with default method
    return(function(data) mice::mice(data,printFlag = FALSE))
  } else {
    stop("Unsupported imputation method specified")
  }
}

iartest <- function(Z, X, Y, G = 'mice', S = NULL, L = 10000, 
                    verbose = FALSE, covariate_adjustment = FALSE, alpha = 0.05, 
                    alternative = "one-sided", random_state = NULL) {
  
  # Parameter checks (implement check_param in R)
  check_param(Z, X, Y, S, G, L, verbose, covariate_adjustment, alpha, alternative, random_state)
  
  # Set random seed if provided
  if (!is.null(random_state)) {
    set.seed(random_state)
  }
  
  # Preprocess the variables (implement preprocess in R)
  M <- is.na(Y)

  if (is.null(S)) {
    S <- rep(1, nrow(X))
  }

  Z <- matrix(Z, ncol = 1)
  S <- matrix(S, ncol = 1)
  
  # Choose the imputation model
  G_model <- choosemodel(G)
  
  # Impute the missing values to get observed test statistics
  # Implement getY and getT in R
  Y_pred <- getY(G_model, Z, X, Y, covariate_adjustment)
  t_obs <- getT(Y_pred, Z, ncol(Y), M)
  
  # Initialize variable for simulations
  p_values <- numeric(ncol(Y))
  
  # Perform simulations
  for (i in 1:L) {
    # Simulate treatment indicators (implement getZsimTemplates and getZsim in R)
    Z_sim <- getZsim(getZsimTemplates(Z, S))
    Z_sim <- matrix(Z_sim, ncol = 1)
    
    # Re-impute and calculate test statistics
    Y_pred_sim <- getY(G_model, Z_sim, X, Y, covariate_adjustment)
    t_sim <- getT(Y_pred_sim, Z_sim, ncol(Y), M)
    
    # Update p-values (implement the logic for calculating p-values)
    if (alternative == "one-sided") {
      p_values <- p_values + (t_sim >= t_obs)
    } else {
      p_values <- p_values + (abs(t_sim - mean(t_sim)) >= abs(t_obs - mean(t_sim)))
    }
  }
  p_values <- p_values / L
  
  # Holm-Bonferroni correction
  corrected_p_values <- p.adjust(p_values, method = "holm")
  any_rejected <- any(corrected_p_values < alpha)
  
  return(list(reject = any_rejected, p_values = corrected_p_values))
}




# Defining the data
Z <- c(1, 1, 1, 1, 0, 0, 0, 0)
X <- matrix(c(5.1, 4.9, 4.7, 4.5, 7.2, 8.6, 6.0, 8.4,
              3.5, NA, 3.2, NA, 2.3, 3.1, 3.6, 3.9), ncol = 2, byrow = TRUE)
Y <- matrix(c(4.4, 4.3, 4.1, 5.0, 1.7, NA, 1.4, 1.7,
              0.5, 0.7, NA, 0.4, 0.1, 0.2, NA, 0.4), ncol = 2, byrow = TRUE)

# Running the iartest function
# Ensure that iartest and all its dependent functions are defined in your R environment
result <- iartest(Z = Z, X = X, Y = Y, L = 1000, verbose = TRUE)
print(result)