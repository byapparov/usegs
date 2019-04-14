context("usegs")

describe("use_gs_acceptance()", {
  it("creates local files from a given spreadsheet", {
    use_gs_acceptance(
      x = "1bkoQYLYAVqgP4bCoqVe-yDB1mdX83cFtOqJ7q8GkT-w",
      extension = "csv"
    )

    multiple.files.in <- c(
      "purchase_order_approved",
      "eta_etd_changed",
      "sud_updated",
      "order_intake_complete"
    )

    tab.names <- c(multiple.files.in, "single-file-in", "file-out")
    file.name <- "usegs-acceptance"
    expected.file.paths <- paste0("tests/testthat/data/", file.name, "/", tab.names, ".csv")
    expect_true(all(file.exists(expected.file.paths)))
  })
})

describe("make_acceptance_test()", {
  it("creates acceptance test R file in testthat folder", {
    test.title <- "customers-test"
    data.files <- c(
      "tests/testhat/customers.csv",
      "tests/testhat/orders.csv"
    )
    res <- make_acceptance_test(
      title = test.title,
      files = data.files
    )

    expect_equal(res, "tests/testthat/test-customers-test.R")

  })
})

describe("code_read_test_file()", {
  it("creates R code to extract test data into variable", {
    res <- code_read_test_file("tests/testthat/customers.csv")
    expect_equal(trimws(res), "customers.csv <- read.csv(\"customers.csv\")")
  })
})
