# MetGENE Dockerization — Session Summary

This document records, in chronological order, every change made while dockerizing MetGENE and debugging it to functional parity with the production deployment at `bdcw.org/MetGENE/`.

## New files added

| File | Purpose |
|---|---|
| `Dockerfile` | Builds a `php:8.2-apache` image with R, all required R/system packages, and the app itself |
| `docker-compose.yml` | `docker compose up --build` entry point: builds the image, publishes port 80, mounts `./cache` |
| `.dockerignore` | Excludes `.git`, docs, and local cache/log files from the build context |
| `apache/000-default.conf` | Custom Apache vhost (see step 5 below for why this replaced a simpler first attempt) |
| `DOCKER_README.md` | Usage instructions for running the container |
| `data/hsa_metSYMBOLs.txt`, `data/mmu_metSYMBOLs.txt`, `data/rno_metSYMBOLs.txt` | Static gene-symbol reference lists, missing from the repo entirely (see step 9) |

## Modified files

`extractGeneIDsAndSymbols.R`, `extractGeneInfoTable.R`, `extractMWGeneSummary.R`, `geneInfo.php`, `metGene.php`, `metabolites.php`, `mgSummary.php`, `nav.php`, `reactions.php`, `studies.php`, `summary.php`, `Dockerfile`, `apache/000-default.conf`, `docker-compose.yml`

---

## Step-by-step history

### 1. Initial Docker setup review
Reviewed the first draft of the Docker files and found three build/runtime-breaking issues:

- **`docker-compose.yml` was completely empty** — `docker compose up --build` failed outright with "empty compose file". Wrote a real compose file (build context, `80:80` port mapping, `./cache` bind mount).
- **REST-style URLs 404'd.** `apache/metgene-rewrite.conf`'s `RewriteRule` pattern (`^rest/...`) was missing the leading slash required when the rule lives in server/vhost context (confirmed via `LogLevel rewrite:trace8`: the rule was being evaluated but never matched the incoming `/rest/...` path).
- **`library(tuple)`** was loaded (unused) at the top of `extractGeneIDsAndSymbols.R`, `extractGeneInfoTable.R`, and `extractMWGeneSummary.R`. The `tuple` package isn't installable on R 4.5 (`install.packages` silently failed in the Dockerfile without stopping the build), so every R script that loaded it crashed instantly — meaning nearly every PHP page that shells out to Rscript rendered blank/broken with no visible error. Removed the three `library(tuple)` lines and dropped `tuple` from the Dockerfile's install list.

Verified end-to-end against `bdcw.org/MetGENE/mgSummary.php?species=hsa&GeneSym=ALDOB&GeneID=229` — pathway/reaction/metabolite/study counts matched exactly (7/4/7/351).

### 2. First manual test — port not published
User's own `docker run` (no `-p` flag) produced a container with no host port mapping, so `localhost` couldn't reach it. Walked through the correct manual sequence (`docker build`, `docker run -d -p 80:80 -v ...`), explaining the missing piece.

### 3. Root cause: app hardcodes paths for subdirectory deployment
Testing `mgSummary.php` and `geneInfo.php` at the web root surfaced two related but independent bugs, both stemming from the app assuming it's always deployed under `/MetGENE/` (as production is):

- **PHP side**: `dirname($_SERVER['PHP_SELF'])` returns `"/"` for a root-level request, producing doubled `//images/...` asset paths (protocol-relative URLs the browser tried to resolve against a nonexistent host `images`) — broken logo/favicon/CSS.
- **R side**: `currDir <- paste0("/", basename(getwd()))` returned `/html` (basename of `/var/www/html`), breaking the Pathways/Reactions/Metabolites/Studies cross-links generated inside the summary table (they pointed to `/html/pathways.php`, a 404).

**Fix chosen** (after trying and reverting a narrower per-file `rtrim()` patch that only fixed the PHP side): restructure the Docker deployment to serve the app from `/MetGENE/` exactly like production, fixing both bugs with zero app-code changes.
- `Dockerfile`: `COPY . /var/www/html/MetGENE` instead of `/var/www/html`; cache dir moved to match.
- `apache/000-default.conf` rewritten as a full vhost: redirects `/` → `/MetGENE/`, and the REST rewrite rule now matches `/MetGENE/rest/...`.
- `docker-compose.yml`: cache volume mount path updated to `/var/www/html/MetGENE/cache`.
- `DOCKER_README.md`: URLs updated to the `/MetGENE/`-prefixed form.

Verified: pathway/reaction/metabolite/study links and images all resolved correctly after rebuild.

### 4. Also suppressed PHP warning/notice display
The base `php:8.2-apache` image ships with development-style `php.ini` (`display_errors = On`), so every page was covered in visible PHP warnings/deprecation notices that don't appear on production. Swapped in `php.ini-production` in the Dockerfile (`mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"`).

### 5. Missing external dependency: gene-ID resolution API
`geneInfo.php` (via `extractGeneIDsAndSymbols.R`) crashed with "cannot open the connection to `https://localhost/geneid/rest/...`". Traced to `$domainName = $_SERVER['SERVER_NAME'];` in **7 files** (`nav.php`, `mgSummary.php`, `studies.php`, `metabolites.php`, `geneInfo.php`, `reactions.php`, `summary.php`) — this value is used to build a call to a **separate REST API that only exists at `bdcw.org/geneid/...`**, not part of this repository. On production, `SERVER_NAME` correctly resolves to `bdcw.org`; locally it was `localhost`, which has no such service.

Confirmed the container has outbound internet access and that `https://bdcw.org/geneid/rest/...` returns correct real data. With user confirmation, hardcoded `$domainName = "bdcw.org";` in all 7 files (each with an explanatory inline comment). Two *other* `SERVER_NAME` usages (`mgSummary.php:117`, `footer.php:25`) were deliberately left untouched — those build self-referencing "Home" links and must keep pointing at the local host.

### 6. `extractGeneInfoTable.R`: two independent, unrelated crashes
Fixing step 5 exposed that the *next* stage of the gene-info pipeline was separately broken two different ways:

- **Corrupted line endings**: this file (uniquely among all 7 R scripts) had doubled `\r\r\n` line endings instead of the `\r\n` every sibling script uses. `Rscript file.R` (but not R's `parse()`) chokes on this with `Error: unexpected invalid token in ""`, failing before any output at all. Pre-existing corruption, unrelated to any earlier edit in this session (confirmed by diffing against every other R script). Normalized with `perl -i -pe 's/\r\r\n/\r\n/g'`.
- **Missing R package**: `ddply(..., .parallel = TRUE)` hard-requires the `foreach` package, which was never in the Dockerfile's install list. Added `r-cran-foreach`.

Verified: `geneInfo.php?...GeneInfoStr=RPE` now returns a gene-info table matching production exactly (same KEGG/NCBI/Ensembl/UniProt/MARRVEL values).

### 7. PHP 8 fatal errors: unquoted bareword string literals
Two more pages went blank partway through rendering:

- **`metabolites.php:179`**: `if ($value != NA)` — bare `NA` instead of the string `"NA"`.
- **`metGene.php:312-315`**: link labels built as bare `.Pathways.`, `.Reactions.`, `.Metabolites.`, `.Studies.` instead of quoted strings.

Both were tolerated by PHP 7 (deprecation warning only) but are fatal `Undefined constant` errors in PHP 8. Grepped the whole codebase afterward for the same pattern — no other occurrences found. Quoted all five bareword literals.

### 8. Missing static data file
`metGene.php` unconditionally reads `data/{species}_metSYMBOLs.txt` (a plain list of metabolic gene symbols, unrelated to the KEGG-license-gated precompute pipeline described in `setPrecompute.R`) via `file_get_contents()` with no existence check. This file was never committed to the repo for any of the three supported species. Confirmed it's plain public data, fetched `hsa_`, `mmu_`, and `rno_metSYMBOLs.txt` directly from the live production server, and added them to `data/`.

Verified: Home tab now shows the full descriptive paragraph and metabolic-gene check that were previously silently truncating the page.

### 9. Home-page content differences — investigated, left as-is
User flagged visual differences on the Home page (a separate "Phenotype" filter column and different footer contact text on production vs. local). Investigated via `git log`: both differences trace back to this repo's **very first commit** — the separate Phenotype dropdown is literally commented out in `index.php`, and the footer text has always read as it does locally. This is a genuine divergence between what's checked into this repository and what's currently live on `bdcw.org` — not a Docker or environment bug. Per explicit user decision, left the repo content unchanged rather than reverting it to match production. Separately verified every image referenced on the Home page (icons, logos, banner) returns HTTP 200 — no actual broken images.

---

## Net result

A `docker compose up --build` (or manual `docker build` + `docker run -p 80:80 -v ./cache:/var/www/html/MetGENE/cache`) now serves the app at `http://localhost/MetGENE/` with output verified to match `bdcw.org/MetGENE/` byte-for-byte on the data fields tested: gene summary counts, gene-info table (KEGG/NCBI/Ensembl/UniProt/MARRVEL), metabolite tables, and pathway/reaction/metabolite/study cross-links.
