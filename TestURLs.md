# MetGENE
A tool for extraction of gene-centric information from the Metabolomics Workbench

URLs to test that the MetGENE tool is working well.

The MetGENE tool is available through the web at <a href="https://bdcw.org/MetGENE">MetGENE</a> and also as a REST API 
(<a href="https://smart-api.info/ui/342e4cec92030d74efd84b61650fb0ea">SmartAPI for MetGENE</a>). The SmartAPI page provides an explanation of the various parameters.

# On bdcw.org

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

https://bdcw.org/MetGENE/rest/summary/species/hsa/GeneIDType/SYMBOL/GeneInfoStr/HK1/anatomy/NA/disease/NA/phenotype/NA/viewType/json

https://bdcw.org/MetGENE/rest/summary/species/hsa/GeneIDType/SYMBOL/GeneInfoStr/HK1,RPE/anatomy/NA/disease/NA/phenotype/NA/viewType/json

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


# On sc-cfdewebdev.sdsc.edu

## For REST API-based access to integrate in user’s existing tools:

URLs to use for json output with CLI (e.g., using [curl -L 'URL']; use /viewType/txt for text output):

Reactions:

https://sc-cfdewebdev.sdsc.edu/MetGENE/rest/reactions/species/hsa/GeneIDType/SYMBOL/GeneInfoStr/HK1/anatomy/NA/disease/NA/phenotype/NA/viewType/json

https://sc-cfdewebdev.sdsc.edu/MetGENE/rest/reactions/species/hsa/GeneIDType/ENSEMBL/GeneInfoStr/ENSG00000000419/anatomy/NA/disease/NA/phenotype/NA/viewType/json

Metabolites:

https://sc-cfdewebdev.sdsc.edu/MetGENE/rest/metabolites/species/hsa/GeneIDType/SYMBOL/GeneInfoStr/HK1/anatomy/NA/disease/Diabetes/phenotype/NA/viewType/txt

https://sc-cfdewebdev.sdsc.edu/MetGENE/rest/metabolites/species/hsa/GeneIDType/SYMBOL/GeneInfoStr/HK1,RPE/anatomy/NA/disease/Diabetes/phenotype/NA/viewType/json

https://sc-cfdewebdev.sdsc.edu/MetGENE/rest/metabolites/species/hsa/GeneIDType/ENSEMBL/GeneInfoStr/ENSG00000000419/anatomy/NA/disease/Diabetes/phenotype/NA/viewType/json

Studies:

https://sc-cfdewebdev.sdsc.edu/MetGENE/rest/studies/species/hsa/GeneIDType/SYMBOL/GeneInfoStr/HK1/anatomy/NA/disease/Diabetes/phenotype/NA/viewType/json

https://sc-cfdewebdev.sdsc.edu/MetGENE/rest/studies/species/hsa/GeneIDType/SYMBOL/GeneInfoStr/HK1,ALDOB/anatomy/NA/disease/Diabetes/phenotype/NA/viewType/json

Summary view:

https://sc-cfdewebdev.sdsc.edu/MetGENE/rest/summary/species/hsa/GeneIDType/SYMBOL/GeneInfoStr/HK1/anatomy/NA/disease/NA/phenotype/NA/viewType/json

https://sc-cfdewebdev.sdsc.edu/MetGENE/rest/summary/species/hsa/GeneIDType/SYMBOL/GeneInfoStr/HK1,RPE/anatomy/NA/disease/NA/phenotype/NA/viewType/json

Please use __ (double underscore) or comma (,) to specify more than one gene, as in the string HK1__PNPLA3 or HK1,RPE. For SYMBOL like IDs, the user may specify SYMBOL_OR_ALIAS for GeneIDType, so that, for gene ID conversion, the term will be first searched in SYMBOL and if not found then it will be searched in ALIAS.

## Examples of (non-REST) API URL for a summary page:

1. Single gene case (Default tab view): Either specify both Gene Symbol and Gene ID (ENTREZ), or specify ENSEMBL ID.

https://sc-cfdewebdev.sdsc.edu/MetGENE/mgSummary.php?species=hsa&ENSEMBL=ENSG00000000419&viewType=all

https://sc-cfdewebdev.sdsc.edu/MetGENE/mgSummary.php?species=hsa&GeneSym=ALDOB&GeneID=229

https://sc-cfdewebdev.sdsc.edu/MetGENE/mgSummary.php?species=hsa&GeneSym=RPE&GeneID=6120&viewType=PIE

https://sc-cfdewebdev.sdsc.edu/MetGENE/mgSummary.php?species=hsa&GeneSym=RPE&GeneID=6120&viewType=BAR

2. Multiple genes case:

https://sc-cfdewebdev.sdsc.edu/MetGENE/mgSummary.php?species=hsa&GeneSym=RPE__ALDOB__GPI&GeneID=6120__229__2821

https://sc-cfdewebdev.sdsc.edu/MetGENE/mgSummary.php?species=hsa&GeneSym=RPE__ALDOB__GPI&GeneID=6120__229__2821&viewType=PIE

https://sc-cfdewebdev.sdsc.edu/MetGENE/mgSummary.php?species=hsa&GeneSym=RPE__ALDOB__GPI&GeneID=6120__229__2821&viewType=BAR

