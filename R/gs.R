#' Function that takes the Google Spreadsheet document key to save it in the working dir
#'
#' @param x key of the Google Sheet document
#' @param extension file extension for local data, either `csv` or `json`. defaults to csv.
#' @export
use_gs_acceptance <- function(x, extension = "csv") {
  path = "tests/testthat/data"
  gap <- googlesheets::gs_key(
    x,
    lookup = FALSE,
    visibility = "private"
  )
  tabs <- gap$ws$ws_title
  title <- clean_dir_name(gap$sheet_title)

  data.dir = paste0(path, "/", title, "/")
  if (!dir.exists(data.dir)) {
    dir.create(data.dir, recursive = TRUE)
  }

  lapply(tabs, function(ws) {
    dt <- googlesheets::gs_read(gap, ws)

    gs_import_worksheet(
      x = dt,
      name = ws,
      dir = data.dir,
      extension = extension
    )
  })

}

#' @noRd
#' @importFrom utils write.csv
#' @import data.table
gs_import_worksheet <- function(x, name, dir, extension) {
  mock_file <- NULL
  save_fn <- make_save_mock_data(extension)

  if ("mock_file" %in% colnames(x)) {
    dt <- data.table::data.table(x)
    mock.files <- unique(dt[, mock_file])
    lapply(mock.files, function(mock.file) {
      save_fn(
        x = dt[mock_file == mock.file, !"mock_file"],
        file.name = mock.file,
        dir = dir
      )
    })
  }
  else {
    save_fn(
      x = x,
      file.name = name,
      dir = dir
    )
  }
}

save_mock_data_json <- function(x, file.name, dir) {
  jsonlite::stream_out(
    x = x,
    con = file(paste0(dir, "/", file.name, ".json"))
  )
}

save_mock_data_csv <- function(x, file.name, dir) {
  write.csv(
    x = x,
    file = paste0(dir, "/", file.name, ".csv"),
    row.names = FALSE
  )
}

make_save_mock_data <- function(extension) {
  switch(extension,
    csv = {
      save_mock_data_csv
    },
    json = {
      save_mock_data_json
    }
  )
}

#' Conforms the name of the directory to be lower case and dash separated
#' @noRd
#' @param x string to turn into a folder name
clean_dir_name <- function(x) {
  x <- tolower(x)
  x <- gsub(" ", "-", x) # replace spaces
  x
}
