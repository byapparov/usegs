#' Function that takes the Google Spreadsheet document key to save it in the working dir
#'
#' @param x key of the Google Sheet document
#' @param extension file extension for local data, either `csv` or `json`. defaults to csv.
#' @export
use_gs_acceptance <- function(x, extension = "csv") {
  gap <- googlesheets::gs_key(
    x,
    lookup = FALSE,
    visibility = "private"
  )
  tabs <- gap$ws$ws_title
  title <- clean_path(gap$sheet_title)

  data.dir <- path_acceptance_data(title)
  if (!dir.exists(data.dir)) {
    dir.create(data.dir, recursive = TRUE)
  }
  save_fn <- make_save_mock_data(data.dir, extension)

  data.files <- import_acceptance_document(gap, tabs, save_fn)
  code.file <- make_acceptance_test(title, data.files)
  message("Inspect the file with acceptance test: ", code.file)
}

path_acceptance_data <- function(title, root = "tests/testthat/data") {
  paste0(root, "/", title)
}

path_acceptance_code <- function(title, root = "tests/testthat") {
  paste0(root, "/", "test-", clean_path(title), ".R")
}

#' Imports Google Sheets document into R project
#'
#' @param gap Google Sheet object received through `googlesheets::gs_key` call.
#' @param tabs names of the document tabs
#' @param save_fn function that saves data from each tab into a local file
#' @noRd
import_acceptance_document <- function(gap, tabs, save_fn) {
  files <- lapply(tabs, function(tab) {
    dt <- googlesheets::gs_read(gap, tab)
    save_acceptance_data(
      x = dt,
      name = tab,
      save_fn = save_fn
    )
  })
  unlist(files)
}

#' Saves data frame from the Google Sheet tab into a local file
#'
#' @param x data frame
#' @param name name of the tab from the Google Sheet
#' @inheritParams gs_import
#' @noRd
#' @importFrom utils write.csv
#' @import data.table
save_acceptance_data <- function(x, name, save_fn) {
  mock_file <- NULL

  if ("mock_file" %in% colnames(x)) {
    dt <- data.table::data.table(x)
    mock.files <- unique(dt[, mock_file])
    lapply(mock.files, function(mock.file) {
      save_fn(
        x = dt[mock_file == mock.file, !"mock_file"],
        file.name = mock.file
      )
    })
  }
  else {
    save_fn(
      x = x,
      file.name = name
    )
  }
}

save_mock_data_json <- function(x, path) {
  jsonlite::stream_out(
    x = x,
    con = file(path)
  )
}

save_mock_data_csv <- function(x, path) {
  write.csv(
    x = x,
    file = path,
    row.names = FALSE
  )
}

path_mock_data <- function(dir, name, extension) {
  paste0(dir, "/", name, ".", extension)
}

#' Creates a function that saves mock data locally
#'
#' @return path to the destination file
#' @noRd
make_save_mock_data <- function(dir, extension) {
  save_fn <- switch(extension,
    csv = {
      save_mock_data_csv
    },
    json = {
      save_mock_data_json
    }
  )

  function(x, file.name) {
    path <- path_mock_data(dir, file.name, extension)
    save_fn(x, path)
    path
  }
}

#' Conforms the name of the directory to be lower case and dash separated
#' @noRd
#' @param x string to turn into a folder name
clean_path <- function(x) {
  x <- tolower(x)
  x <- gsub(" ", "-", x) # replace spaces
  x
}

clean_variable <- function(x) {
  x <- basename(x)
  x <- tolower(x)
  x <- gsub(" |-|_", ".", x) # replace separator chars with dots
  x
}

#' Creates acceptance test file with code that loads acceptance data
#'
#' @param title title of the acceptance test document
#' @param fiels names of the data files that were imported from acceptance document
#' @return path to the target file with code
#' @noRd
make_acceptance_test <- function(title, files) {
  path <- path_acceptance_code(title)

  if (file.exists(path)) {
    message("Test case code file already exists: ", path)
    return(path)
  }

  res <- paste0("context(\"", title, "\")", "\n\n")
  res <- paste0(res, "test_that(\"TODO: test case description\", {\n")

  res.read.data <- lapply(files, function(file) {
    code_read_test_file(file)
  })
  res <- paste0(
    res,
    paste(res.read.data, collapse = "\n"),
    "\n",
    "  # TODO: acceptance test\n",
    "  stop(\"acceptance test is not implemented\")\n",
    "})"
  )

  write(res, file = path)
  path
}

code_read_test_file <- function(file) {
  relative.file.name <- gsub(".*/testthat/", "", file)
  variable.name <- gsub(".*/data/", "", file)
  if (grepl("\\.json", relative.file.name)) {
    paste0("  ", clean_variable(variable.name), " <- jsonlite::stream_in(file(\"", relative.file.name, "\"))")
  }
  else if (grepl("\\.csv", relative.file.name)) {
    paste0("  ", clean_variable(variable.name), " <- read.csv(\"", relative.file.name, "\")")
  }
}

#' Loads acceptance docs based on the yaml config file
#'
#' @export
#' @param config path to the yaml configuration file
refresh_project_acceptance <- function(config = ".acceptance.yml") {
  assertthat::assert_that(file.exists(config))
  acceptance <- yaml::yaml.load_file(config)

  lapply(acceptance$acceptance_documents, function(x) {
    use_gs_acceptance(x$key, x$extension)
  })
}
