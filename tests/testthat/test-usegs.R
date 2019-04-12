context("usegs")

describe("usegs()", {
  it("creates local files from a given spreadsheet", {
    use_gs(
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
