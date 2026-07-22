# Docker setup for MetGENE

This repository now includes a Docker-based Apache + PHP + R setup for local development.

## Run locally

```bash
docker compose up --build
```

Then open:

- http://localhost/MetGENE/ (redirects here automatically from http://localhost/)
- http://localhost/MetGENE/mgSummary.php?species=hsa&GeneSym=ALDOB&GeneID=229
- http://localhost/MetGENE/rest/reactions/species/hsa/GeneIDType/SYMBOL/GeneInfoStr/HK1/anatomy/NA/disease/NA/phenotype/NA/viewType/json

The app is served under `/MetGENE/`, matching the path structure of the production deployment (bdcw.org/MetGENE/) — several PHP and R scripts derive internal links and asset paths from the current URL/working-directory path, so this needs to match for those links to resolve correctly.

The `cache/` directory is mounted as a persistent volume, so generated files stay available between container restarts.

If port 80 is already in use on your machine, change the first value in `docker-compose.yml` from `80:80` to something like `8080:80`.
