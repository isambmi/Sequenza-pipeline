library(sequenza)

args <- commandArgs(trailingOnly = TRUE)
sample.id <- args[1]
seqz.file <- args[2]
num.threads <- suppressWarnings(as.integer(args[3]))

if (is.na(num.threads) || num.threads < 1L) {
  num.threads <- 1L
}

seqz <- sequenza.extract(seqz.file, verbose = FALSE, parallel = num.threads)
cp.table <- sequenza.fit(seqz, mc.cores = num.threads)
sequenza.results(sequenza.extract = seqz,
                 cp.table = cp.table,
                 sample.id = sample.id)
