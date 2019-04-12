#' Function that takes the Google Spreadsheet document key to save it in the working dir
#'
#' @param x key of the Google Sheet document
#' @param extension file extension for local data, either `csv`` or `json`. defaults to csv.
use_gs <- function(x, extension = "csv") {
  path = "tests/testthat/data"

  gap <- googlesheets::gs_key(x, lookup = FALSE, visibility = "private")
  tabs <- gap$ws$ws_title
  title <- gap$sheet_title

  title <- tolower(title)
  title <- gsub(" ", "-", title) # replace spaces
  data.dir = paste0(path, "/", title, "/")
  if (!dir.exists(data.dir)) {
    dir.create(data.dir, recursive = TRUE)
  }

  lapply(tabs, function(ws) {
    dt <- googlesheets::gs_read(gap, ws)

    gs_save_worksheet(
      x = dt,
      name = ws,
      dir = data.dir,
      extension = extension
    )
  })

}

#' @noRd
#' @importFrom utils write.csv
gs_save_worksheet <- function(x, name, dir, extension) {
  mock_file <- NULL
  data.path <- paste0(dir, "/", name, ".", extension)
  if (extension == "csv") {
    write.csv(
      x = x,
      file = data.path,
      row.names = FALSE
    )
  }
  else if (extension == "json") {
    if ("mock_file" %in% colnames(x)) {
      dt <- data.table::data.table(x)
      mock.files <- unique(dt[, mock_file])
      lapply(mock.files, function(mock.file) {

        jsonlite::stream_out(
          x = dt[mock_file == mock.file, !"mock_file"],
          con = file(paste0(dir, "/", mock.file, ".", extension))
        )
      })
    }
    else {
      jsonlite::stream_out(
        x = x,
        con = file(data.path)
      )
    }
  }
  else {
    stop("Only csv and json are excepted as test data formats")
  }
}