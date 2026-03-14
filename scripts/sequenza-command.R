library(sequenza)

args <- commandArgs(trailingOnly=TRUE)
sample.id <- args[1]
seqz.file <- args[2]

seqz <- sequenza.extract(seqz.file, verbose = FALSE)
cp.table <- sequenza.fit(seqz)

run_sequenza_no_plots <- function(seqz_obj, cp.table, sample.id, out.dir) {
  old_pdf <- grDevices::pdf
  
  # Override pdf() locally
  unlockBinding("pdf", as.environment("package:grDevices"))
  assign("pdf", function(...) { invisible(NULL) }, envir = as.environment("package:grDevices"))
  lockBinding("pdf", as.environment("package:grDevices"))
  
  on.exit({
    unlockBinding("pdf", as.environment("package:grDevices"))
    assign("pdf", old_pdf, envir = as.environment("package:grDevices"))
    lockBinding("pdf", as.environment("package:grDevices"))
  }, add = TRUE)
  
  sequenza.results(sequenza.extract = seqz_obj,
    cp.table = cp.table, sample.id = sample.id)
}

run_sequenza_no_plots(seqz_obj = seqz,
    cp.table = cp.table, sample.id = sample.id)