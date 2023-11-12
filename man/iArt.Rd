\name{iArt}
\alias{iArt}
\title{Imputation-Assisted Randomization Tests}
\description{
  Performs Imputation-Assisted Randomization Tests.
}
\usage{
iArt.test(Z, X, Y, G = 'missforest', S = NULL, L = 10000, verbose = FALSE, 
        covariate_adjustment = FALSE, alpha = 0.05, alternative = "one-sided", random_state = NULL)
}
\arguments{
  \item{Z}{Numeric vector of observed treatment indicators.}
  \item{X}{Numeric matrix or data frame of observed covariates.}
  \item{Y}{Numeric matrix or data frame of outcomes with potential missing values.}
  \item{G}{The imputation method. Default is 'missforest'. Other option include 'mice'.}
  \item{S}{Numeric vector of strata indicators. Default is NULL.}
  \item{L}{Number of Monte Carlo simulations. Default is 10000.}
  \item{verbose}{Logical flag for verbose output. Default is FALSE.}
  \item{covariate_adjustment}{Logical flag for performing covariate adjustment. Default is FALSE.}
  \item{alpha}{Significance level for the statistical test. Default is 0.05.}
  \item{alternative}{Specifies the alternative hypothesis. Choices are "one-sided" or "two-sided". Default is "one-sided".}
  \item{random_state}{An integer for setting the random seed. Default is NULL.}
}
\value{
  A list with two elements:
  \itemize{
    \item{reject}{Logical value indicating whether the null hypothesis is rejected for each outcome.}
    \item{p_values}{Numeric vector of p-values for each outcome.}
  }
}
\examples{
Z <- c(1, 1, 1, 1, 0, 0, 0, 0)
X <- matrix(c(5.1, 4.9, 4.7, 4.5, 7.2, 8.6, 6.0, 8.4,
              3.5, NA, 3.2, NA, 2.3, 3.1, 3.6, 3.9), ncol = 2, byrow = TRUE)
Y <- matrix(c(4.4, 4.3, 4.1, 5.0, 1.7, NA, 1.4, 1.7,
              0.5, 0.7, NA, 0.4, 0.1, 0.2, NA, 0.4), ncol = 2, byrow = TRUE)

result <- iArt.test(Z = Z, X = X, Y = Y, L = 1000, verbose = TRUE)
print(result)
}
\seealso{
  \code{\link{mice}}, \code{\link{missForest}}
}
\description{
  Design-based (also known as finite-population or randomization-based) causal inference is one of the most widely used frameworks for testing causal null hypotheses or
  inferring about causal parameters from experimental or observational data. The most
  significant merit of design-based causal inference is that its statistical validity only
  comes from the study design (e.g., randomization design in a randomized experiment)
  and does not require assuming any outcome-generating distributions or models. Although immune to model misspecification, design-based causal inference can still suffer
  from other data challenges, among which missingness in outcomes is a significant one.
  However, compared with model-based (also known as super-population or samplingbased) causal inference, outcome missingness in design-based causal inference is much
  less studied, largely due to the challenge that design-based causal inference does not
  assume any outcome distributions/models and, therefore, cannot directly adopt any
  existing model-based approaches for missing data. To fill this gap, we systematically study the missing outcomes problem in design-based causal inference. First, we
  use the potential outcomes framework to clarify the minimal assumption (concerning
  the outcome missingness mechanism) needed for conducting finite-population-exact
  randomization tests for the null effect (i.e., Fisher’s sharp null) and that needed for
  constructing finite-population-exact confidence sets with missing outcomes. Second,
  we propose a general framework called “imputation and re-imputation" for conducting finite-population-exact randomization tests in design-based causal studies with
  missing outcomes. Our framework can incorporate any existing outcome imputation
  algorithms and meanwhile guarantee finite-population-exact type-I error rate control.
  Third, we extend our framework to conduct covariate adjustment in an exact randomization test with missing outcomes and to construct finite-population-exact confidence
  sets with missing outcomes. We conduct comprehensive simulation studies to examine
  exact type-I error rate control and gains in power using our framework. We have also
  developed an open-source Python package for implementation of our methods
}
