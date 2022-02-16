suppressMessages(library(uwot))

args = commandArgs(trailingOnly=TRUE)

datarray <- read.table(args[1], sep="\t")
datarray <- as.matrix(datarray)

embedding <- umap(datarray, n_threads=max(1, RcppParallel::defaultNumThreads()))
write.table(embedding, file="", sep="\t", row.names=FALSE, col.names=FALSE)
