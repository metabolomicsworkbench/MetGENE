#!/usr/bin/env Rscript
# THis script obtains the reaction information pertaining to the gene input
# Call syntax : Rscript extractReactionInfo.R <species> <geneStr> <viewType> 
# Input: species e.g. hsa, mmu 
#        geneStr : ENTREZID of genes e.g. 3098, 6120 
#        viewType : e.g. json, txt
# Output: A table in json or txt format comprising of reaction information 
#         or html table (if viewType is neither json or txt).
#         The table contains KEGG_REACTION_ID, KEGG_REACTION_NAME KEGG_REACTION_EQUATION

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
