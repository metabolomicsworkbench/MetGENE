# Docker Setup for MetGENE

This repository includes a Docker-based Apache + PHP + R setup for local development. 

The application is served under the `/MetGENE/` path, matching the structure of the production deployment (`bdcw.org/MetGENE/`). This is important because several PHP and R scripts derive internal links and asset paths from the current URL, so this path must match for those links to resolve correctly.

The `cache/` directory is also mounted as a persistent volume, ensuring that generated files stay available between container restarts.

---

## How to Run the Application

You can start the application using either **Docker Compose** (recommended) or standard **Docker commands**.

### Method 1: Using Docker Compose (Recommended)
Docker Compose handles the build, port mapping, and volume setups automatically based on the `docker-compose.yml` file.

1. **Start the application:**
   ```bash
   docker compose up --build
   ```
2. **Handling Port Conflicts:**
   By default, the application tries to run on port `80`. If port `80` is already in use on your machine, the startup will fail. To fix this, open the `docker-compose.yml` file and change the ports setting from `"80:80"` to `"8080:80"` (or another available port).

### Method 2: Using Standard Docker Commands (Manual)
If you prefer not to use Compose, you can build and run the image manually. Note that while the `Dockerfile` declares `EXPOSE 80`, this alone does not make the app accessible to your machine. You must explicitly publish the port using the `-p` flag.

1. **Build the image:**
   ```bash
   docker build -t metgene_metgene:latest .
   ```
2. **Run the container:**
   Map an available port on your machine (e.g., `8080`) to the container's internal port (`80`).
   ```bash
   docker run -d -p 8080:80 --name running-metgene metgene_metgene:latest
   ```

---

## Verifying It Is Running

To ensure the container is running and the port is published correctly, run:

```bash
docker ps
```

Look at the `PORTS` column for your container. You should see something like:
`0.0.0.0:8080->80/tcp` 
*(This confirms your local port 8080 is successfully routing to the container's port 80).*

---

## Accessing the Application

Once the container is running, open MetGENE in your web browser. 

* **If you are using the default port 80:**
  * Main app: [http://localhost/MetGENE/](http://localhost/MetGENE/) *(http://localhost/ will redirect here automatically)*
  * Example query 1: [http://localhost/MetGENE/mgSummary.php?species=hsa&GeneSym=ALDOB&GeneID=229](http://localhost/MetGENE/mgSummary.php?species=hsa&GeneSym=ALDOB&GeneID=229)
  * Example query 2: [http://localhost/MetGENE/rest/reactions/species/hsa/GeneIDType/SYMBOL/GeneInfoStr/HK1/anatomy/NA/disease/NA/phenotype/NA/viewType/json](http://localhost/MetGENE/rest/reactions/species/hsa/GeneIDType/SYMBOL/GeneInfoStr/HK1/anatomy/NA/disease/NA/phenotype/NA/viewType/json)

* **If you changed the port to 8080 (or used `-p 8080:80`):**
  * Main app: [http://localhost:8080/MetGENE/](http://localhost:8080/MetGENE/)
  * Example query 1: [http://localhost:8080/MetGENE/mgSummary.php?species=hsa&GeneSym=ALDOB&GeneID=229](http://localhost:8080/MetGENE/mgSummary.php?species=hsa&GeneSym=ALDOB&GeneID=229)
  * Example query 2: [http://localhost:8080/MetGENE/rest/reactions/species/hsa/GeneIDType/SYMBOL/GeneInfoStr/HK1/anatomy/NA/disease/NA/phenotype/NA/viewType/json](http://localhost:8080/MetGENE/rest/reactions/species/hsa/GeneIDType/SYMBOL/GeneInfoStr/HK1/anatomy/NA/disease/NA/phenotype/NA/viewType/json)
