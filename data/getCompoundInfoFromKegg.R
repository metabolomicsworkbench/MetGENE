# This Rscript generates the precomputed RDS file for compound/metabolite information
# Input: species or organism codelike hsa,mmu, rno
# Output: <species>_keggGet_cpdInfo.RDS
# susrinivasan@ucsd,edu; mano@sdsc.edu

library(tidyverse)
library(plyr)
library(KEGGREST)

remove_prefix <- function(entry) {
  substr(entry, start = 5, stop = nchar(entry))
}

args <- commandArgs(TRUE);
orgStr = args[1]
rdsFilename = paste0("./data/",orgStr,"_keggLink_mg.RDS")
print(rdsFilename)
all_df = readRDS(rdsFilename)
cpds = all_df[str_detect(all_df[,2],"cpd:"),]

cpds$kegg_data <- sapply(cpds$kegg_data, remove_prefix)
metabList = cpds$kegg_data

print(metabList)


query_split = split(metabList,  ceiling(seq_along(metabList)/10))
info = llply(query_split, function(x)keggGet(x)) 
unlist_info <- unlist(info, recursive = F)

extract_info <- lapply(unlist_info, '[', c("ENTRY", "NAME", "REACTION"))

dd=do.call(rbind, extract_info)                                                                                  
cpdInfodf = data.frame(dd)


cpdInfodf = cpdInfodf[!duplicated(cpdInfodf$ENTRY),]
rownames(cpdInfodf) = cpdInfodf$ENTRY
metfilename = paste0("./data/", orgStr, "_keggGet_cpdInfo.RData")
print(metfilename)
save(cpdInfodf,file = metfilename)
#metfilenameRDS = paste0("./data/", orgStr, "_keggGet_cpdInfo.RDS")
#saveRDS(cpdInfodf, file = metfilenameRDS, ascii = FALSE, version = NULL, compress = TRUE, refhook = NULL)

