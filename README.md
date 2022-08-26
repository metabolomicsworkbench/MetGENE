# GeneIDConversion
Conversion of one type of gene ID (such as SYMBOL or ENTREZ gene ID) into other types of IDs (such as ENSEMBL or UNIPROT)

Genomic and gene expression data is integral to biomolecular data analysis. The types of identifiers used for genes differ across different resources providing such data sets. The ability to use a single type of gene identifier is imperative for integrating data from two or more resources. This gene ID conversion tool facilitates the use of a common gene identifier. A <a href="https://bdcw.org/MW/docs/geneid_conversion_20220822.pdf">tutorial</a> provides an overview and the steps of how to use this tool.

This tool is available through the web at https://bdcw.org/geneid/geneidconv.php Gene ID Conversion</a> and also as a REST API 
(<a href="https://smart-api.info/ui/e712b9eb07e637a00ae468f757ce2a1f">SmartAPI for Gene ID Conversion</a>). The SmartAPI page provides an explanation of the various parameters.

## For API-based access to integrate in user’s existing tools:

URLs to use for json output with CLI (e.g., using [curl -L 'URL']; use /View/txt for text output):

https://bdcw.org/geneid/rest/species/hsa/GeneIDType/SYMBOL_OR_ALIAS/GeneListStr/AIM1/View/json

https://bdcw.org/geneid/rest/species/hsa/GeneIDType/SYMBOL_OR_ALIAS/GeneListStr/ITPR3__IL6__KLF4/View/json

Please use __ (double underscore) to specify more than one gene, as in the string ITPR3__IL6__KLF4 in the example above.

## How to use it in a python program:

A python script provides an example of how to use the gene ID conversion tool. At the core, a URL-based query is constructed and executed using python packages “requests” and “bs4” (function “BeutifulSoup”). After some processing, the results are available as a pandas dataframe.

Example python script: https://bdcw.org/geneid/fetch_php_page.py
