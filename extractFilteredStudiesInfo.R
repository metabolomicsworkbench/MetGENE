#!/usr/bin/env Rscript
# THis script extracts the studies information pertaining to the gene input
# Call syntax : Rscript extractFilteredStudiesInfo.R <species> <geneArray> <diseaseStr> <anatomyStr> <viewTypeStr>
# Input: species e.g. hsa, mmu 
#        geneArray : comma separated list (no spaces) of ENTREZID of one or more genes e.g. 3098,6120 (ENTREZID arrary of genes)
#        diseaseStr: e.g. Diabetes, Cancer, NA (if not planning to use)
#        anatomyStr : e.g. Blood, Brain, NA (if not planning to use)
#        viewTypeStr : e.g. json, txt
# Output: A table in json or txt format comprising of study information 
#         or a html table (if viewType is neither json or txt).
#         The table contains KEGG Rxn IDs, Rxn Description and Rxn equation.

library(KEGGREST);
library(stringr);
library(rlang)
library(data.table);
library(xtable);
library(jsonlite);
library(httr);
library(rvest);
library(tictoc);
library(tidyverse);

# set flag for precompute tables
source("setPrecompute.R")
list_of_list_to_df <- function(jslist) {
    if (length(jslist) > 0) {


                                        # Convert character columns to numeric
        if (class(jslist[[1]])=="list") {
            dt <- rbindlist(jslist, fill=TRUE)
            jsdf = dt[, c("kegg_id", "refmet_name", "study", "study_title")]
            return(jsdf)

        } else {
            jsdf = as.data.frame(t(as.data.frame(unlist(jslist))));
            jsdf = jsdf[, c("kegg_id", "refmet_name", "study", "study_title")]
            return(jsdf)
        }
    } else {
        return(NULL)
    }
}


getMetaboliteStudiesForGene <- function(orgId, geneArray, diseaseId, anatomyId, viewType) {
    if(orgId %in% c("Human","human","hsa","Homo sapiens")) {
        organism_name = "Human";
    } else if(orgId %in% c("Mouse","mouse","mmu","Mus musculus")) {
        organism_name = "Mouse";
    } else if(orgStr %in% c("Rat","rat","rno","Rattus norvegicus")) {
        organism_name = "Rat";
    }
    studiesTableDF =  data.frame(matrix(ncol = 3, nrow = 0), stringsAsFactors = False)  
    metabStudyDF = data.frame(matrix(ncol = 7, nrow = 0), stringsAsFactors = False)
    colnames(metabStudyDF) = c("refmet_name", "study", "study_urls", "select", "kegg_id", "refmetname_url", "keggid_url")
    metabStudyList <- list();
    metabList <- list();

    ## Get compounds and reactions for all genes.



    for (g in 1:length(geneArray)) {
        queryStr = paste0(orgId,":",geneArray[g]);
        if (preCompute == 1) {
          ## Get studies, reactions pertaining to compounds from RDS file
          rdsFilename = paste0("./data/",orgId,"_keggLink_mg.RDS")
          all_df = readRDS(rdsFilename)

          df <- subset(all_df, org_ezid == queryStr)
        } else {
          df <- keggLink(queryStr)
        }
# All compounds pertaining to the gene are prefixed by cpd:
        cpds <- df[str_detect(df[,2],"cpd:"),2];
# Prune the prefixes so that the list comprises of only the ids
        metabList <- append(metabList,gsub("cpd:", "", cpds));

    }

    metabList <- unique(metabList)
    
    anatomyQryStr = anatomyId
    diseaseQryStr = diseaseId
    if (!is_empty(anatomyId) && length(anatomyId) > 0 && str_detect(anatomyId, " ")) {
        anatomyQryStr = str_replace_all(anatomyId, " ", "+");
    }

    if (!is_empty(diseaseId) && length(diseaseId) > 0 && str_detect(diseaseId, " ")) {
        diseaseQryStr = str_replace_all(diseaseId, " ", "+");
    }  
    

    
    if (length(metabList) > 0) {

        for (m in 1:length(metabList)){
            metabStr = metabList[[m]];
           #     print(metabStr);

            ## Need this to get RefMet Names, study-ids, study titles
                                        #      tic("Time taken for studies info per compound")
            path = paste0("https://www.metabolomicsworkbench.org/rest/metstat/;;", organism_name, ";", anatomyQryStr, ";", diseaseQryStr, ";", metabStr);
#            print(path)
            jslist <- read_json(path, simplifyVector = TRUE);
                                        #      toc()
            respDF <- list_of_list_to_df(jslist); 
            mydf_studies <- respDF[, c("refmet_name", "kegg_id", "study", "study_title")]

            if (!is.null(mydf_studies)) {
                ##      multiple refmet IDs case, loop through and create an entry for each variant

                url_df <- mydf_studies %>% mutate(study_urls = paste0("<a href=\"https://www.metabolomicsworkbench.org/data/DRCCMetadata.php?Mode=Study&StudyID=", study, "\" target=\"blank\" title=\"", study_title, "\"> ", study, " </a>"))

                url_df = url_df  %>% mutate(keggid_url =  paste0("<a href = \"https://www.genome.jp/entry/cpd:",kegg_id,"\">",kegg_id,"</a>"))

                url_df <- url_df %>%  mutate(refmetname_url = paste0("<a href=\"https://www.metabolomicsworkbench.org/databases/refmet/refmet_details.php?REFMET_NAME=", str_replace_all(refmet_name, c("\\+" = "%2b", " " = "+")), "\" target=\"_blank\"> ", refmet_name, "</a>"))
                refmetnameURLDF = unique(url_df$refmetname_url)
                keggidDF = unique(url_df$kegg_id)
                keggidURLDF = unique(url_df$keggid_url)
                result_df <- aggregate(cbind(study, study_urls) ~ refmet_name, data = url_df, FUN = function(x) c(paste(x, collapse = ", ")))

                result_df = result_df %>% mutate(select = paste0("<input type=\"checkbox\"/>"))
                result_df = cbind(result_df, kegg_id=keggidURLDF, refmetname_url = refmetnameURLDF, keggid_url = keggidURLDF)


                metabStudyDF = rbind(metabStudyDF, result_df)

            } else {
                # get metabolite name from KeGG
                kegg_id = metabStr
                keggid_url = paste0("<a href = \"https://www.genome.jp/entry/cpd:",metabStr,"\">",metabStr,"</a>")
                refmet_name = ""
                refmetname_url = " "
                study = ""

                study_urls = "No studies found"
                select = "" 
                result_df = data.frame(kegg_id = kegg_id, refmet_name = refmet_name, study = study, study_urls = study_urls, keggid_url = keggid_url, refmetname_url = refmetname_url, select = select) 
                metabStudyDF = rbind(metabStudyDF, result_df)
            } 

            

        }
    }

    vtFlag = tolower(viewType);

    if (vtFlag == "json") {
        studiesTableDF = metabStudyDF[, c("kegg_id","refmet_name","study")]
        colnames(studiesTableDF) = c("KEGG_COMPOUND_ID", "REFMET_NAME", "STUDY_ID")
        studyJson  <-  toJSON(x=studiesTableDF, pretty=T);
        return(cat(toString(studyJson)));
    } else if (vtFlag == "txt") {
        studiesTableDF = metabStudyDF[, c("kegg_id","refmet_name","study")]
        colnames(studiesTableDF) = c("KEGG_COMPOUND_ID", "REFMET_NAME", "STUDY_ID")
        return(cat(format_csv(studiesTableDF)));
    } else {
        if (nrow(metabStudyDF) > 0) {
            tableDF = metabStudyDF[, c("select", "kegg_id","refmetname_url", "study_urls")]
            tableDF$study_urls <- gsub(",", "", tableDF$study_urls)
            colnames(tableDF) = c('SELECT', 'KEGGMETABID','REFMETNAME',  'STUDIES')
            nprint =  nrow(tableDF);
            return(print(xtable(tableDF[1:nprint,]), type="html", include.rownames=FALSE, sanitize.text.function=function(x){x}, html.table.attributes="id='Table1' class='styled-table'"));
        } else {
            return(print(paste0(" Does not code for metabolites")));
        }
    }

}


args <- commandArgs(TRUE);
species <- args[1];
geneArray <- as.vector(strsplit(args[2],split=",",fixed=TRUE)[[1]]);
diseaseStr <- args[3];
anatomyStr <- args[4];
viewTypeStr  <- args[5];
##geneArray <- c(3098,229);
if (diseaseStr == "NA") {
    diseaseStr = "";
}
if (anatomyStr == "NA") {
    anatomyStr = "";
}
#tic("Time elapsed = ")
outhtml <- getMetaboliteStudiesForGene(species, geneArray, diseaseStr, anatomyStr, viewTypeStr)
#toc()
