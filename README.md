# MetGENE
A tool for extraction of gene-centric information from the Metabolomics Workbench

[MetGENE tutorial](https://bdcw.org/MW/docs/MetGENETutorial.pdf)

Given one or more genes, the MetGENE tool identifies associations between the gene(s) and the metabolites that are biosynthesized, metabolized, or transported by proteins coded by the genes. The gene(s) link to metabolites, the chemical transformations involving the metabolites through gene-specified proteins/enzymes, the functional association of these gene-associated metabolites and the pathways involving these metabolites. 

The user can specify the gene using a multiplicity of IDs and gene ID conversion tool translates these into harmonized IDs that are basis at the computational end for metabolite associations. Further, all studies involving the metabolites associated with the gene-coded proteins, as present in the [Metabolomics Workbench (MW)](https://www.metabolomicsworkbench.org/), the portal for the NIH Common Fund National Metabolomics Data Repository (NMDR), will be accessible to the user through the portal interface. The user can begin her/his journey from the [NIH Common Fund Data Ecosystem (CFDE) portal](https://app.nih-cfde.org/chaise/recordset/#1/CFDE:gene@sort(nid)). 

The data from MW studies are presented as table(s), with the metabolite names hyperlinked to MW RefMet page (or to the corresponding KEGG entry in the absence of a RefMet name) for the metabolite, the reactions hyperlinked to their KEGG entries and the MW studies hyperlinked to their respective pages. The user also has access to the metabolite statistics via MetStat. Further, the user has the option to select more than one metabolite to list only those studies in which all the selected metabolites appear and can download the table as a text, HTML or JSON file.

The MetGENE tool is available through the web at <a href="https://bdcw.org/MetGENE">MetGENE</a> and also as a REST API 
(<a href="https://smart-api.info/ui/342e4cec92030d74efd84b61650fb0ea">SmartAPI for MetGENE</a>). The SmartAPI page provides an explanation of the various parameters.

The MetGENE tool has been also registered at <a href="https://scicrunch.org/resources/data/record/nlx_144509-1/SCR_023402/resolver?q=SCR_023402&l=SCR_023402&i=rrid:scr_023402">SciCrunch RRID Portal</a>: RRID:SCR_023402.

## (Upcoming) MetGENE source code (R, php and supporting files)

We also provide the source code so that one can clone this tool and run it locally as a web application. KEGG APIs are used in this tool. Please see their license terms at https://www.kegg.jp/kegg/legal.html (see also https://www.pathway.jp/en/academic.html). While no KEGG license is required to run the web app on user's localhost (e.g., access as localhost:install_location_withrespectto_DocumentRoot/MetGENE, or, restrict its access to the IP addresses belonging to their own research group), if the user wishes to provide this tool (or their own tool based on a subset of this tool involving use of KEGG APIs) as a service (see LICENSE), they must obtain their own KEGG license with suitable rights.

## For REST API-based access to integrate in user’s existing tools:

URLs to use for json output with CLI (e.g., using [curl -L 'URL']; use /viewType/txt for text output):

Reactions:

https://bdcw.org/MetGENE/rest/reactions/species/hsa/GeneIDType/SYMBOL/GeneInfoStr/HK1/anatomy/NA/disease/NA/phenotype/NA/viewType/json

https://bdcw.org/MetGENE/rest/reactions/species/hsa/GeneIDType/ENSEMBL/GeneInfoStr/ENSG00000000419/anatomy/NA/disease/NA/phenotype/NA/viewType/json

Metabolites:

https://bdcw.org/MetGENE/rest/metabolites/species/hsa/GeneIDType/SYMBOL/GeneInfoStr/HK1/anatomy/NA/disease/Diabetes/phenotype/NA/viewType/txt

https://bdcw.org/MetGENE/rest/metabolites/species/hsa/GeneIDType/SYMBOL/GeneInfoStr/HK1,RPE/anatomy/NA/disease/Diabetes/phenotype/NA/viewType/json

https://bdcw.org/MetGENE/rest/metabolites/species/hsa/GeneIDType/ENSEMBL/GeneInfoStr/ENSG00000000419/anatomy/NA/disease/Diabetes/phenotype/NA/viewType/json

Studies:

https://bdcw.org/MetGENE/rest/studies/species/hsa/GeneIDType/SYMBOL/GeneInfoStr/HK1/anatomy/NA/disease/Diabetes/phenotype/NA/viewType/json

https://bdcw.org/MetGENE/rest/studies/species/hsa/GeneIDType/SYMBOL/GeneInfoStr/HK1,ALDOB/anatomy/NA/disease/Diabetes/phenotype/NA/viewType/json

Summary view:

Please note that for the summary view, the filters anatomy, disease and phenotype are required as a placeholder (to maintain the order of the parameter names), but are not used in the actual computation. An important reason for this is that summary results are precomputed for faster processing and the actual use of these filters would have resulted in too many combinations to precompute.

https://bdcw.org/MetGENE/rest/summary/species/hsa/GeneIDType/SYMBOL/GeneInfoStr/HK1/anatomy/NA/disease/NA/phenotype/NA/viewType/json

https://bdcw.org/MetGENE/rest/summary/species/hsa/GeneIDType/SYMBOL/GeneInfoStr/HK1,RPE/anatomy/NA/disease/NA/phenotype/NA/viewType/json

https://bdcw.org/MetGENE/rest/summary/species/hsa/GeneIDType/SYMBOL/GeneInfoStr/PNPLA3/anatomy/NA/disease/NA/phenotype/NA/viewType/json

Please use __ (double underscore) or comma (,) to specify more than one gene, as in the string HK1__PNPLA3 or HK1,RPE. For SYMBOL like IDs, the user may specify SYMBOL_OR_ALIAS for GeneIDType, so that, for gene ID conversion, the term will be first searched in SYMBOL and if not found then it will be searched in ALIAS.

## Examples of (non-REST) API URL for a summary page:

1. Single gene case (Default tab view): Either specify both Gene Symbol and Gene ID (ENTREZ), or specify ENSEMBL ID.

https://bdcw.org/MetGENE/mgSummary.php?species=hsa&ENSEMBL=ENSG00000000419&viewType=all

https://bdcw.org/MetGENE/mgSummary.php?species=hsa&GeneSym=ALDOB&GeneID=229

https://bdcw.org/MetGENE/mgSummary.php?species=hsa&GeneSym=RPE&GeneID=6120&viewType=PIE

https://bdcw.org/MetGENE/mgSummary.php?species=hsa&GeneSym=RPE&GeneID=6120&viewType=BAR

2. Multiple genes case: 

https://bdcw.org/MetGENE/mgSummary.php?species=hsa&GeneSym=RPE__ALDOB__GPI&GeneID=6120__229__2821

https://bdcw.org/MetGENE/mgSummary.php?species=hsa&GeneSym=RPE__ALDOB__GPI&GeneID=6120__229__2821&viewType=PIE

https://bdcw.org/MetGENE/mgSummary.php?species=hsa&GeneSym=RPE__ALDOB__GPI&GeneID=6120__229__2821&viewType=BAR

