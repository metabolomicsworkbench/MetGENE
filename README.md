# MetGENE
A tool for extraction of gene-centric information from Metabolomics Workbench DCC

Given one or more genes, the MetGENE tool identifies the reactions catalyzed by the corresponding protein(s) and the related metabolites; gene ID conversion is also performed. For each metabolite, the studies containing the metabolite are identified from the [Metabolomics Workbench (MW)](https://www.metabolomicsworkbench.org/) Data Coordination Center (DCC) of [NIH Common Fund Data Ecosystem (CFDE)](https://commonfund.nih.gov/dataecosystem).

The results are presented as a table, with the metabolite names hyperlinked to MW RefMet page (or to the corresponding KEGG entry in the absence of a RefMet name) for the metabolite, reaction hyperlinked to its KEGG entry and MW studies hyperlinked to their respective pages. The user also has access to the studies statistics via MW MetStat. Further, the user has the option to select more than one metabolite to list only those studies in which all the selected metabolites appear and can download the table as a text, HTML or JSON file. 

The MetGENE tool is available through the web at <a href="https://bdcw.org/MetGENE">MetGENE</a> and also as a REST API 
(<a href="https://smart-api.info/ui/342e4cec92030d74efd84b61650fb0ea">SmartAPI for Gene ID Conversion</a>). The SmartAPI page provides an explanation of the various parameters.

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

