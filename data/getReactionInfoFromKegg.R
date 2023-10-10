# This Rscript generates the precomputed RDS file for the reaction information
# Input: species or organism codelike hsa,mmu, rno
# Output: <species>_keggGet_rnxInfo.RDS
# susrinivasan@ucsd,edu; mano@sdsc.edu
 
library(tidyverse)
library(plyr)
library(KEGGREST)

remove_prefix <- function(entry) {
  substr(entry, start = 4, stop = nchar(entry))
}

args <- commandArgs(TRUE);
orgStr = args[1]
rdsFilename = paste0("./data/",orgStr,"_keggLink_mg.RDS")
print(rdsFilename)
all_df = readRDS(rdsFilename)
rxns = all_df[str_detect(all_df[,2],"rn:"),]

rxns$kegg_data <- sapply(rxns$kegg_data, remove_prefix)
rxnsList = rxns$kegg_data

print(rxnsList)


query_split = split(rxnsList,  ceiling(seq_along(rxnsList)/10))
info = llply(query_split, function(x)keggGet(x)) 
unlist_info <- unlist(info, recursive = F)

extract_info <- lapply(unlist_info, '[', c("ENTRY", "NAME", "DEFINITION"))

dd=do.call(rbind, extract_info)                                                                                  
rxnInfodf = data.frame(dd)
colnames(rxnInfodf) =  c("ENTRY", "NAME", "DEFINITION")

rxnInfodf = rxnInfodf[!duplicated(rxnInfodf$ENTRY),]
rownames(rxnInfodf) = rxnInfodf$ENTRY
rxnfilename = paste0("./data/", orgStr, "_keggGet_rxnInfo.RDS")
print(rxnfilename)
saveRDS(rxnInfodf, file = rxnfilename, ascii = FALSE, version = NULL, compress = TRUE, refhook = NULL)

