context("usegs")

describe("usegs()", {
  it("creates local files from a given spreadsheet", {
    use_gs(
      x = "1bkoQYLYAVqgP4bCoqVe-yDB1mdX83cFtOqJ7q8GkT-w",
      extension = "csv"
    )

    tab.names <- c("multiple-files-in", "single-file-in", "file-out")
    file.name <- "usegs-acceptance"
    expected.file.paths <- paste0("tests/testthat/data/", file.name, "/", tab.names, ".csv")
    print(expected.file.paths)
    print(file.exists(expected.file.paths))
    expect_true(all(file.exists(expected.file.paths)))
  })
})