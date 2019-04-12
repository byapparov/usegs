# usegs

usegs package allows easy copy of Goolge Sheets to local project files. Acceptance files or other data where Google Sheet is source can be easiliy copied.

## Installation

You can install usegs from github with:


``` r
# install.packages("devtools")
devtools::install_github("byapparov/usegs")
```

## Example

This is a basic example which shows you how to save acceptance data into testthat data folder:

``` r
## This code ran in the working directory of package will create files in `tests/testthat/data/{sheet-name}/` folder
use_gs(
  x = "1bkoQYLYAVqgP4bCoqVe-yDB1mdX83cFtOqJ7q8GkT-w",
  extension = "csv"
)
```
