library(sequenza)

args <- commandArgs(trailingOnly=TRUE)
sample.id <- args[1]
seqz.file <- args[2]
num.threads <- args[3]

seqz <- sequenza.extract(seqz.file, verbose = FALSE, parallel = num.threads)
cp.table <- sequenza.fit(seqz, mc.cores = num.threads)
sequenza.results(sequenza.extract = seqz,
    cp.table = cp.table, sample.id = sample.id)
