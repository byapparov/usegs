[![Build Status](https://travis-ci.org/byapparov/usegs.svg?branch=master)](https://travis-ci.org/byapparov/usegs)
[![codecov.io](https://codecov.io/github/yapparov/usegs/coverage.svg?branch=master)](https://codecov.io/github/byapparov/usegs?branch=master)


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
## This code ran in the working directory of package 
## will create files in `tests/testthat/data/{sheet-name}/` folder
use_gs_acceptance(
  x = "1bkoQYLYAVqgP4bCoqVe-yDB1mdX83cFtOqJ7q8GkT-w",
  extension = "csv"
)
```

You can also refresh data for all of your acceptance tests if you maintain `.acceptance.yml` file.

This file contains simple structure that references Google Sheets:

```yaml
# .acceptance.yml file in working directory of the project or package
acceptance_documents:
  - key: '1bkoQYLYAVqgP4bCoqVe-yDB1mdX83cFtOqJ7q8GkT-w' # Google Sheet key
    extension: csv # defines how data will be saved localy
    description: Accceptance file example 1 # you can add other fields for documentation purposes
    story: ST-100

  - key: '2bkoQYLYAVqgP4bCoqVe-yDB1mdX83cFtOqJ7q8GkT-x'
    extension: json
    description: Accceptance file example 2
    story: ST-200
```

```r
# Running this function will save data from all acceptance 
# Google Sheet files localy in 'tests/testthat/data/{doc title}/' folders
refresh_project_acceptance()
```
