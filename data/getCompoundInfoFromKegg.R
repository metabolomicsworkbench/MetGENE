# This Rscript generates the precomputed RDS file for compound/metabolite information
# Call syntax: Rscript getCompoundInfoFromKegg.R <species>
# Input: species or organism code like hsa,mmu, rno
# Output: <species>_keggGet_cpdInfo.RDS containing compound or metabolite information from KEGG
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
  substr(entry, start = 5, stop = nchar(entry))
}

args <- commandArgs(TRUE);
orgStr = args[1]
rdsFilename = paste0("./",orgStr,"_keggLink_mg.RDS")
print(rdsFilename)
all_df = readRDS(rdsFilename)
cpds = all_df[str_detect(all_df[,2],"cpd:"),]

cpds$kegg_data <- sapply(cpds$kegg_data, remove_prefix)
metabList = cpds$kegg_data

print(metabList)


query_split = split(metabList,  ceiling(seq_along(metabList)/100))
info = llply(query_split, function(x)keggGet(x)) 
unlist_info <- unlist(info, recursive = F)

extract_info <- lapply(unlist_info, '[', c("ENTRY", "NAME", "REACTION"))

dd=do.call(rbind, extract_info)                                                                                  
cpdInfodf = data.frame(dd)


cpdInfodf = cpdInfodf[!duplicated(cpdInfodf$ENTRY),]
rownames(cpdInfodf) = cpdInfodf$ENTRY
metfilename = paste0("./", orgStr, "_keggGet_cpdInfo.RData")
print(metfilename)
save(cpdInfodf,file = metfilename)
#metfilenameRDS = paste0("./data/", orgStr, "_keggGet_cpdInfo.RDS")
#saveRDS(cpdInfodf, file = metfilenameRDS, ascii = FALSE, version = NULL, compress = TRUE, refhook = NULL)

