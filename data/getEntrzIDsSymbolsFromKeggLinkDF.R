# This R script generates SYMBOLS and EntrzIDs for use in copmuteGeneAssociations.R 
# Input: species of organism code liks hsa, mmu, rno
# Output: <specis>_metSYMBOLs.txt, <species>_metENTRZIDs.txt, <species>_metENTRZIDsAndSYMBOLs.txt
# susrinivasan@ucsd.edu ; mano@sdsc.edu

library(jsonlite)                                                                                                                                                 

source("../geneid/idconv_auxfun.R")

args <- commandArgs(TRUE);
species = args[1]
print(species)
rdsFileName = paste0("./data/", species,"_keggLink_mg.RDS")
print(rdsFileName)
df = readRDS(rdsFileName)
org_entrzIds = df$org_ezid
print(head(org_entrzIds))
# removes orgId out of entrzId
extract_substring <- function(string) {
  substr(string, start = 5, stop = nchar(string))
}

entrz_ids = unique(sapply(org_entrzIds, extract_substring))
write.csv(entrz_ids,"./rnoEntrezIDs.csv")

geneListStr = "24157__24158__24159__24161"
geneListStr = paste0(entrz_ids, collapse = "__")
GeneAllInfo_list = get_GeneAllInfo(organism_name = species, GeneListStr = geneListStr, GeneIDType = "ENTREZID", selcolnames = c("SYMBOL", "ENTREZID"), addKEGG = 0, returnHTML = 0
);
GeneAllInfo = GeneAllInfo_list$GeneAllInfo;
symboldf = unique(GeneAllInfo$SYMBOL);
data_unique <- unique(GeneAllInfo[ , c("ENTREZID", "SYMBOL")])
colnames(data_unique) = c("ENTREZID", "SYMBOL")
#url_str_gene_php = paste0("https://bdcw.org/geneid/rest/species/", species,"/GeneIDType/ENTREZID/GeneListStr/", geneInfoArray, "/View/json");
#GeneAllInfo = fromJSON(url_str_gene_php, simplifyVector = TRUE); 
#newdf = GeneAllInfo[c("SYMBOL")];
#symboldf =  unique(newdf);
write.table(entrz_ids, paste0("data/",species,"_metEntrzIDs.txt"), sep="\n", col.names=FALSE, row.names=FALSE, quote=FALSE)
write.table(symboldf, paste0("data/",species,"_metSYMBOLs.txt"), sep = "\n", col.names=FALSE, row.names=FALSE, quote=FALSE)
write.table(data_unique, paste0("data/",species,"_metENTREZIDsAndSYMBOLs.txt"), sep = "\n", row.names=FALSE, quote=FALSE)
