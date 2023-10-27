# This Rscript generates the precomputed RDS file for the reaction information from KEGG
# Call syntax: Rscript getReactionInfoFromKegg.R <species>
# Input: species or organism codelike hsa,mmu, rno
# Output: <species>_keggGet_rnxInfo.RDS containing reaction information from KEGG
# susrinivasan@ucsd,edu; mano@sdsc.edu
 
################################################
# Restrictions due to the use of KEGG APIs (https://www.kegg.jp/kegg/legal.html, see also https://www.pathway.jp/en/academic.html)
# * Using this code to provide user's own web service
# The code we provide is free for non-commercial use (see LICENSE). While it is our understanding that no KEGG license is required to run the web app on user's local computer for personal use (e.g., access as localhost:install_location_withrespectto_DocumentRoot/MetGENE, or, restrict its access to the IP addresses belonging to their own research group), the users must understand the KEGG license terms (https://www.kegg.jp/kegg/legal.html, see also https://www.pathway.jp/en/academic.html) and decide for themselves. For example, if the user wishes to provide this tool (or their own tool based on a subset of MetGENE scripts with KEGG APIs) as a service (see LICENSE), they must obtain their own KEGG license with suitable rights.
# * Faster version of MetGENE
# If and only if the user has purchased license for KEGG FTP Data, they can activate a 'preCompute' mode to run faster version of MetGENE. To achieve this, please set preCompute = 1 in the file setPrecompute.R. Otherwise, please ensure that preCompute is set to 0 in the file setPrecompute.R. Further, to use the faster version, the user needs to run the R scripts in the 'data' folder first. Please see the respective R files in the 'data' folder for instructions to run them.
# Please see the files README.md and LICENSE for more details.
################################################

library(tidyverse)
library(plyr)
library(KEGGREST)

remove_prefix <- function(entry) {
  substr(entry, start = 4, stop = nchar(entry))
}

args <- commandArgs(TRUE);
orgStr = args[1]
rdsFilename = paste0("./",orgStr,"_keggLink_mg.RDS")
print(rdsFilename)
all_df = readRDS(rdsFilename)
rxns = all_df[str_detect(all_df[,2],"rn:"),]

rxns$kegg_data <- sapply(rxns$kegg_data, remove_prefix)
rxnsList = rxns$kegg_data

#print(rxnsList)


query_split = split(rxnsList,  ceiling(seq_along(rxnsList)/100))
length(query_split)
info = llply(query_split, function(x)keggGet(x)) 
unlist_info <- unlist(info, recursive = F)

extract_info <- lapply(unlist_info, '[', c("ENTRY", "NAME", "DEFINITION"))

dd=do.call(rbind, extract_info)                                                                                  
rxnInfodf = data.frame(dd)
colnames(rxnInfodf) =  c("ENTRY", "NAME", "DEFINITION")

rxnInfodf = rxnInfodf[!duplicated(rxnInfodf$ENTRY),]
rownames(rxnInfodf) = rxnInfodf$ENTRY
rxnfilename = paste0("./", orgStr, "_keggGet_rxnInfo.RDS")
print(rxnfilename)
saveRDS(rxnInfodf, file = rxnfilename, ascii = FALSE, version = NULL, compress = TRUE, refhook = NULL)

