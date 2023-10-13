# This Rscript is used to obtain the keggLink information and save
# as a precomputed RDS to be loaded in the backend R scripts for MetGENE
# Call Syntax: Rscript getKEGGLinkDataForGenes.R <species>
# Input : species code (hsa, mmu,rno)
# Output: <species>_keggLink_mg,RDS (containing info for all metabolic genes pnly from KEGG

################################################
# Restrictions due to the use of KEGG APIs (https://www.kegg.jp/kegg/legal.html, see also https://www.pathway.jp/en/academic.html)
# * Using this code to provide user's own web service
# The code we provide is free for non-commercial use (see LICENSE). While it is our understanding that no KEGG license is required to run the web app on user's local computer for personal use (e.g., access as localhost:install_location_withrespectto_DocumentRoot/MetGENE, or, restrict its access to the IP addresses belonging to their own research group), the users must understand the KEGG license terms (https://www.kegg.jp/kegg/legal.html, see also https://www.pathway.jp/en/academic.html) and decide for themselves. For example, if the user wishes to provide this tool (or their own tool based on a subset of MetGENE scripts with KEGG APIs) as a service (see LICENSE), they must obtain their own KEGG license with suitable rights.
# * Faster version of MetGENE
# If and only if the user has purchased license for KEGG FTP Data, they can activate a 'preCompute' mode to run faster version of MetGENE. To achieve this, please set preCompute = 1 in the file setPrecompute.R. Otherwise, please ensure that preCompute is set to 0 in the file setPrecompute.R. Further, to use the faster version, the user needs to run the R scripts in the 'data' folder first. Please see the respective R files in the 'data' folder for instructions to run them.
# Please see the files README.md and LICENSE for more details.
################################################

library(KEGGREST)
library(tidyverse)
library(plyr)

getKEGGLinkDataForGenes <- function(species) {
    infn = paste0("data/", species, "_keggLink.RDS");
    mgfn = paste0("data/", species, "_keggLink_mg.RDS"); # "hsa_keggLink_mg.RDS";

    load_from_RDS = 1;

    if(tolower(species) %in% c("human","hsa","homo sapiens")){
	entrezID_df = read.table("data/Homo_sapiens.gene_info_20220517.txt_proteincoding_ENTREZID.txt", header = TRUE)
    }  else if(tolower(species) %in% c("mouse","mmu","mus musculus")){
	entrezID_df = read.table("data/Mus_musculus.gene_info_20220517.txt_proteincoding_ENTREZID.txt", header = TRUE)
    } else if(tolower(species) %in% c("rat","rno","rattus norvegicus")){
	entrezID_df = read.table("data/Rattus_norvegicus.gene_info_20220517.txt_proteincoding_ENTREZID.txt", header = TRUE)
    }

    geneVec = entrezID_df$ENTREZID
    all_df = data.frame()

                                        #geneVec = c("6120", "3098" , "9314"); 
    for (i in 1:length(geneVec)){
        g = geneVec[i]
        queryStr = paste0(species, ":",g)
                                        #  print(queryStr)
        df <- keggLink(queryStr)
                                        # check whether the genes have reactions
###rxns <- df[str_detect(df[,2],"rn:"),2];
                                        #  print(rxns)
###if (length(rxns) != 0) {
        all_df = rbind(all_df, data.frame(df))
###}
    }
    df = all_df;

    colnames(df) = c("org_ezid", "kegg_data", "relation_type")
    saveRDS(df, file = infn)

    #library(tictoc); tic('Time to load'); df=readRDS(infn); toc()

    rn_ind = grep("rn:", df[,2]); mgid = unique(df[rn_ind,1]); length(mgid);
    dfmg = df[df[,1] %in% mgid, ];
    dfmg = dfmg[grep("cpd:|rn:|path:", dfmg[,2]),]; # add any others you need

    dim(df)
    dim(dfmg)

    saveRDS(dfmg, file = mgfn, ascii = FALSE, version = NULL, compress = TRUE, refhook = NULL)
#    tic('load time of dfmg');
    dfmg = readRDS(mgfn); 
#    toc();

                                        # test example
    if(species %in% c("hsa")){
        gl = c("hsa:3098","hsa:80339","hsa:6120", "hsa:3417", "hsa:5730", "hsa:4190");
#        tic("Time to extract subset for a set of genes:");
        subdf = dfmg[dfmg[,1] %in% gl, ];
#        toc();
        # Time to extract subset for a set of genes:: 0.004 sec elapsed
    }

                                        # Code block to use KEGGLINK or load saved RDS file
    measure_compute_time = 0;

    run_this_code = 0;

    if(run_this_code == 1){
        if(load_from_RDS==0){
                                        # Call KEGGLINK
        } else {
            if(measure_compute_time==1) { tic('load time of dfmg');}
            dfmg = readRDS(mgfn);
            if(measure_compute_time==1) { toc(); }
        }
    } else{
                                        # do nothing
    }
}

args <- commandArgs(TRUE);
species <- args[1];
getKEGGLinkDataForGenes(species)
