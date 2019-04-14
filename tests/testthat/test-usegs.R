context("usegs")

mock_gs_key <- function(...) {
  load("data/gap.rda")
  get("gap")
}

mock_gs_read <- function(ss, ws) {
  load(paste0("data/", ws, ".rda"))
  get(gsub("-", ".", ws))
}


describe("use_gs_acceptance()", {
  it(
    "creates local files from a given spreadsheet",
    with_mock(
      `googlesheets::gs_key` = mock_gs_key,
      `googlesheets::gs_read` = mock_gs_read, {

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
        expected.file.paths <- paste0(
          "tests/testthat/data/",
          file.name, "/",
          tab.names, ".csv"
        )

        expect_true(all(file.exists(expected.file.paths)))

        use_gs_acceptance(
          x = "1bkoQYLYAVqgP4bCoqVe-yDB1mdX83cFtOqJ7q8GkT-w",
          extension = "json"
        )
        expected.file.paths <- paste0(
          "tests/testthat/data/",
          file.name, "/",
          tab.names, ".json"
        )
        expect_true(all(file.exists(expected.file.paths)))
      }
    )
  )
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
  it("messages if acceptance test R file already exists", {

    test.title <- "customers-test"
    data.files <- c(
      "tests/testhat/customers.csv",
      "tests/testhat/orders.csv"
    )
    expect_message(
      make_acceptance_test(
        title = test.title,
        files = data.files
      ),
      regexp = "exists"
    )
  })
})

describe("code_read_test_file()", {
  it("creates R code to extract test data into variable", {
    res <- code_read_test_file("tests/testthat/data/file.csv")
    expect_equal(
      trimws(res),
      "file.csv <- read.csv(\"data/file.csv\")"
    )

    res <- code_read_test_file("tests/testthat/data/file.json")
    expect_equal(
      trimws(res),
      "file.json <- jsonlite::stream_in(file(\"data/file.json\"))"
    )
  })
})

describe("refresh_project_acceptance()", {
  it("calls use_gs_acceptance() for each key in the config file", {
    mock_use_gs_acceptance <- mockery::mock()
    with_mock(
      use_gs_acceptance = mock_use_gs_acceptance, {
        refresh_project_acceptance()
        mockery::expect_called(mock_use_gs_acceptance, 2)
        mockery::expect_args(
          mock_use_gs_acceptance,
          n = 1,
          x = "1bkoQYLYAVqgP4bCoqVe-yDB1mdX83cFtOqJ7q8GkT-w",
          extension = "csv"
        )
        mockery::expect_args(
          mock_use_gs_acceptance,
          n = 2,
          x = "2bkoQYLYAVqgP4bCoqVe-yDB1mdX83cFtOqJ7q8GkT-x",
          extension = "json"
        )
      }
    )
  })
})