# This Rscript generates the precomputed RDS file for summary table information
# Input: species or organism codelike hsa,mmu, rno
# Dependencies : Also reguires <species>_metSYMBOLs,txt which is a list of metabolic gene symbols.
#              : This file can be generated using getEntrzIDsSymbolsFromKeggLinkDF.R
# Output: <species>_summaryTable.RDS
# susrinivasan@ucsd.edu; mano@sdsc.edu
library(httr)
library(jsonlite)
library(dplyr)
library(tidyjson)

options <- commandArgs(trailingOnly = TRUE)
organism <- options[1]
print(paste0("Organism = ", organism))
# Define the function to connect to the URL and return a JSON object
errorgenes = vector()

get_json <- function(mystring) {
  if(organism == "test") {
    url <- paste0("https://sc-cfdewebdev.sdsc.edu/MetGENE/rest/summary/species/hsa/GeneIDType/SYMBOL_OR_ALIAS/GeneInfoStr/", mystring, "/anatomy/NA/disease/NA/phenotype/NA/viewType/json")
  } else {
    url <- paste0("https://sc-cfdewebdev.sdsc.edu/MetGENE/rest/summary/species/",organism,"/GeneIDType/SYMBOL_OR_ALIAS/GeneInfoStr/", mystring, "/anatomy/NA/disease/NA/phenotype/NA/viewType/json")
  }
  response <- GET(url)
  content <- rawToChar(response$content)
  print(url)
  tryCatch({ 
      json <- fromJSON(content)
      return(json)
  }, error =  function(e) { 
      message(paste0("No entries found for ", mystring))
      errorgenes <- c(errorgenes, mystring)
    return(NULL)
  })

}

# Define the vector of strings
in_file_path = paste0(organism,"_metSYMBOLs.txt")
print(in_file_path)
lines <- readLines(in_file_path)
metDF = data.frame(SYMBOL = lines, stringsAsFactors = FALSE)
#metDF = read.table(in_file_path)

#metDF = read.table(paste0("test","_keggGenes.txt"), header = FALSE)
#metDF = read.csv("missing_genes.txt", header = FALSE)


metGenesVec <- metDF$SYMBOL
print(head(metGenesVec))
# Apply the function to each element of the vector
json_list <- lapply(metGenesVec, get_json)
df <- bind_rows(json_list)

print(df)
file_path = paste0("./",organism,"_summaryTable.RDS")
saveRDS(df, file = file_path)
