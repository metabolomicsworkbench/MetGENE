#!/usr/bin/env Rscript
# THis script obtains the reaction information pertaining to the gene input
# Call syntax : Rscript extractReactionInfo.R <species> <geneStr> <viewType> 
# Input: species e.g. hsa, mmu 
#        geneStr : ENTREZID of genes e.g. 3098, 6120 
#        viewType : e.g. json, txt
# Output: A table in json or txt format comprising of reaction information 
#         or html table (if viewType is neither json or txt).
#         The table contains KEGG_REACTION_ID, KEGG_REACTION_NAME KEGG_REACTION_EQUATION

################################################
# Restrictions due to the use of KEGG APIs (https://www.kegg.jp/kegg/legal.html, see also https://www.pathway.jp/en/academic.html)
# * Using this code to provide user's own web service
# The code we provide is free for non-commercial use (see LICENSE). While it is our understanding that no KEGG license is required to run the web app on user's local computer for personal use (e.g., access as localhost:install_location_withrespectto_DocumentRoot/MetGENE, or, restrict its access to the IP addresses belonging to their own research group), the users must understand the KEGG license terms (https://www.kegg.jp/kegg/legal.html, see also https://www.pathway.jp/en/academic.html) and decide for themselves. For example, if the user wishes to provide this tool (or their own tool based on a subset of MetGENE scripts with KEGG APIs) as a service (see LICENSE), they must obtain their own KEGG license with suitable rights.
# * Faster version of MetGENE
# If and only if the user has purchased license for KEGG FTP Data, they can activate a 'preCompute' mode to run faster version of MetGENE. To achieve this, please set preCompute = 1 in the file setPrecompute.R. Otherwise, please ensure that preCompute is set to 0 in the file setPrecompute.R. Further, to use the faster version, the user needs to run the R scripts in the 'data' folder first. Please see the respective R files in the 'data' folder for instructions to run them.
# Please see the files README.md and LICENSE for more details.
################################################

library(KEGGREST);
library(stringr);
library(data.table);
library(xtable);
library(jsonlite);
library(tidyverse);
library(plyr)
library(tictoc)

# setting the precompute flag
source("setPrecompute.R")

getReactionInfoTable <- function(orgStr, geneIdStr, viewType) {


  queryStr = paste0(orgStr, ":", geneIdStr)

  if (preCompute == 1) {
    # Load RDS file containing keggLink information
  
    rdsFilename = paste0("./data/", orgStr,"_keggLink_mg.RDS")
    all_df = readRDS(rdsFilename)
    # obtain the information for the species:gene 
    df <- subset(all_df, org_ezid == queryStr)
  } else {
    df = keggLink(queryStr)
  }
  # obtain reaction information
  rxns <- df[str_detect(df[,2],"rn:"),2];
  # obtain only the reaction IDs
  rxnList <- as.vector(gsub("rn:", "", rxns));
  if (preCompute == 1) {
  # Load RDS file for reaction info and get it for rxnList
    rxnInfodf = readRDS(paste0("./data/",orgStr,"_keggGet_rxnInfo.RDS"))
    rxndf <- rxnInfodf[rownames(rxnInfodf) %in% rxnList, ]
    rxndf <- data.frame(lapply(rxndf, function(x) gsub("\"", "", x)))
  } else {
  # Obtain reaction information from KEGG
    query_split = split(rxnList,  ceiling(seq_along(rxnList)/10))
    info = llply(query_split, function(x)keggGet(x))
    unlist_info <- unlist(info, recursive = F)
    extract_info <- lapply(unlist_info, '[', c("ENTRY", "NAME", "DEFINITION")) 
    dd=do.call(rbind, extract_info)
    rxndf = as.data.frame(dd)
    rxndf <- data.frame(lapply(rxndf, function(x) gsub("\"", "", x)))
  }
  # Add additional KEGG_REACTION_URL for html display
  colnames(rxndf) = c("KEGG_REACTION_ID", "KEGG_REACTION_NAME", "KEGG_REACTION_EQN")
  rxndf$KEGG_REACTION_URL <- paste0("<a href=\"https://www.genome.jp/entry/rn:", rxndf$KEGG_REACTION_ID, "\" target=\"_blank\">", rxndf$KEGG_REACTION_ID, "</a>")    
#  print(rxndf)



  vtFlag = tolower(viewType);
    
  if (vtFlag == "json") {
     newdf = rxndf[, c("KEGG_REACTION_ID", "KEGG_REACTION_NAME", "KEGG_REACTION_EQN")]
     newdf = cbind(Gene = geneIdStr, newdf);
     rxnJson <- toJSON(x = newdf, pretty = T);
     return(cat(toString(rxnJson)));
  } else if (vtFlag == "txt") {
     newdf = rxndf[, c("KEGG_REACTION_ID", "KEGG_REACTION_NAME", "KEGG_REACTION_EQN")]
     newdf = cbind(Gene = geneIdStr, newdf);
     return(cat(format_csv(newdf)));
  } else {
      newdf = rxndf[, c("KEGG_REACTION_URL", "KEGG_REACTION_NAME", "KEGG_REACTION_EQN")];
      colnames(newdf) = c("KEGG_REACTION_ID","KEGG_REACTION_NAME", "KEGG_REACTION_EQN");
     nprint = nrow(newdf);

     tableprint <- xtable(newdf[1:nprint,]);
     tableAttr = paste0("id = 'Gene",geneIdStr,"Table' class='styled-table'");
     return(print(xtable(newdf[1:nprint,]), type="html", include.rownames=FALSE, sanitize.text.function=function(x){x}, html.table.attributes=tableAttr));
  }
}

args <- commandArgs(TRUE);
species <- args[1];
geneStr <- args[2];
viewType  <- args[3];
##print(jsonFlag);
#tic()
outhtml <- getReactionInfoTable(species, geneStr, viewType)
#toc()
