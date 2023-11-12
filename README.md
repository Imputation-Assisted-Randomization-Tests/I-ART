# iArt: Imputation-Assisted Randomization Tests

## Authors

Siyu Heng*, Jiawei Zhang*, and Yang Feng (* indicates equal contribution)

## Maintainers

Siyu Heng (Email: siyuheng@nyu.edu), Jiawei Zhang (Email: jz4721@nyu.edu), and Yang Feng (Email: yang.feng@nyu.edu)

## Description

iArt (Imputation-Assisted Randomization Tests) is a R package designed for conducting finite-population-exact randomization tests in design-based causal studies with missing outcomes. It offers a robust solution to handle missing data in causal inference, leveraging the potential outcomes framework and integrating various outcome imputation algorithms.

## Installation

To install iArt, run the following command:

```bash
devtools::install_github("Imputation-Assisted-Randomization-Tests/iArt")
```

## Usage

Here is a basic example of how to use iArt:

```R
library(iArt)
Z <- c(1, 1, 1, 1, 0, 0, 0, 0)
X <- matrix(c(5.1, 3.5, 4.9, 4.0, 4.7, 3.2, 4.5, 5, 7.2, 2.3, 8.6, 3.1, 6.0, 3.6, 8.4, 3.9), ncol = 2)
Y <- matrix(c(4.4, 4.3, NA, 5.0, 1.1, NA, 1.4, 1.7), ncol = 1, byrow = TRUE)
result <- iArt.test(Z = Z, X = X, Y = Y, L = 100,covariate_adjustment = TRUE, verbose = TRUE)
print(result)
```

Detailed usage can be found here [ReadDoc](https://i-art.readthedocs.io/en/latest/)

## Features

- Conducts finite-population-exact randomization tests.
- Handles missing data in causal inference studies.
- Supports various outcome imputation algorithms.
- Offers covariate adjustment in exact randomization tests.


## Contributing

Your contributions to iArt are highly appreciated! If you're looking to contribute, we encourage you to open issues for any bugs or feature suggestions, or submit pull requests with your proposed changes. 


## License
This project is licensed under the MIT License

## Citation
If you use iArt in your research, please consider citing it:

```code
@misc{heng2023designbased,
      title={Design-Based Causal Inference with Missing Outcomes: Missingness Mechanisms, Imputation-Assisted Randomization Tests, and Covariate Adjustment}, 
      author={Siyu Heng and Jiawei Zhang and Yang Feng},
      year={2023},
      eprint={2310.18556},
      archivePrefix={arXiv},
      primaryClass={stat.ME}
}
```
