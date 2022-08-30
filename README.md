# MetGENE
A tool for extraction of gene-centric information from the Metabolomics Workbench

Given one or more genes, the MetGENE tool identifies associations between the gene(s) and the metabolites that are biosynthesized, metabolized, or transported by proteins coded by the genes. The gene(s) link to metabolites, the chemical transformations involving the metabolites through gene-specified proteins/enzymes, the functional association of these gene-associated metabolites and the pathways involving these metabolites.

The user can specify the gene using a multiplicity of IDs and gene ID conversion tool translates these into harmonized IDs that are basis at the computational end for metabolite associations. Further, all studies involving the metabolites associated with the gene-coded proteins, as present in the [Metabolomics Workbench (MW)](https://www.metabolomicsworkbench.org/), the portal for the NIH Common Fund National Metabolomics Data Repository (NMDR), will be accessible to the user through the portal interface. The user can begin her/his journey from the [NIH Common Fund Data Ecosystem (CFDE) portal](https://app.nih-cfde.org/chaise/recordset/#1/CFDE:gene@sort(nid)). 

The data from MW studies are presented as table(s), with the metabolite names hyperlinked to MW RefMet page (or to the corresponding KEGG entry in the absence of a RefMet name) for the metabolite, the reactions hyperlinked to their KEGG entries and the MW studies hyperlinked to their respective pages. The user also has access to the metabolite statistics via MetStat. Further, the user has the option to select more than one metabolite to list only those studies in which all the selected metabolites appear and can download the table as a text, HTML or JSON file.

The MetGENE tool is available through the web at <a href="https://bdcw.org/MetGENE">MetGENE</a> and also as a REST API 
(<a href="https://smart-api.info/ui/342e4cec92030d74efd84b61650fb0ea">SmartAPI for MetGENE</a>). The SmartAPI page provides an explanation of the various parameters.

## For API-based access to integrate in user’s existing tools:

URLs to use for json output with CLI (e.g., using [curl -L 'URL']; use /viewType/txt for text output):

Reactions:
https://bdcw.org/MetGENE/rest/reactions/species/hsa/GeneIDType/SYMBOL/GeneInfoStr/HK1/anatomy/NA/disease/NA/phenotype/NA/viewType/json

Metabolites:
https://bdcw.org/MetGENE/rest/metabolites/species/hsa/GeneIDType/SYMBOL/GeneInfoStr/HK1/anatomy/NA/disease/Diabetes/phenotype/NA/viewType/txt

Studies:
https://bdcw.org/MetGENE/rest/studies/species/hsa/GeneIDType/SYMBOL/GeneInfoStr/HK1/anatomy/NA/disease/Diabetes/phenotype/NA/viewType/json

Please use __ (double underscore) to specify more than one gene, as in the string HK1__PNPLA3. For SYMBOL like IDs, the user may specify SYMBOL_OR_ALIAS for GeneIDType, so that, for gene ID conversion, the term will be first searched in SYMBOL and if not found then it will be searched in ALIAS.

## Examples of API URL for a summary page:

1. Single gene case (Default tab view): 

https://bdcw.org/MetGENE/mgSummary.php?species=hsa&ENSEMBL=ENSG00000000419&viewType=all

https://bdcw.org/MetGENE/mgSummary.php?species=hsa&GeneSym=ALDOB&GeneID=229

https://bdcw.org/MetGENE/mgSummary.php?species=hsa&GeneSym=RPE&GeneID=6120&viewType=PIE

https://bdcw.org/MetGENE/mgSummary.php?species=hsa&GeneSym=RPE&GeneID=6120&viewType=BAR

2. Multiple genes case: 

https://bdcw.org/MetGENE/mgSummary.php?species=hsa&GeneSym=RPE__ALDOB__GPI&GeneID=6120__229__2821

https://bdcw.org/MetGENE/mgSummary.php?species=hsa&GeneSym=RPE__ALDOB__GPI&GeneID=6120__229__2821&viewType=PIE

https://bdcw.org/MetGENE/mgSummary.php?species=hsa&GeneSym=RPE__ALDOB__GPI&GeneID=6120__229__2821&viewType=BAR

