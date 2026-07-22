FROM php:8.2-apache

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        r-base \
        r-base-dev \
        r-cran-curl \
        r-cran-data.table \
        r-cran-dplyr \
        r-cran-foreach \
        r-cran-ggplot2 \
        r-cran-ggrepel \
        r-cran-httr \
        r-cran-jsonlite \
        r-cran-plyr \
        r-cran-readr \
        r-cran-reshape2 \
        r-cran-rlang \
        r-cran-rvest \
        r-cran-stringi \
        r-cran-stringr \
        r-cran-tidyr \
        r-cran-tidyverse \
        r-cran-xtable \
        r-cran-xml2 \
        libcurl4-openssl-dev \
        libssl-dev \
        libxml2-dev \
        libfontconfig1-dev \
        libharfbuzz-dev \
        libfribidi-dev \
        libfreetype6-dev \
        libpng-dev \
        libtiff5-dev \
        libjpeg-dev \
        libicu-dev \
        libgit2-dev \
        libcairo2-dev \
        libxt-dev \
        pkg-config \
        ca-certificates \
        curl \
        wget \
        bzip2 \
        gnupg \
    && rm -rf /var/lib/apt/lists/*

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

RUN a2enmod rewrite

COPY apache/000-default.conf /etc/apache2/sites-available/000-default.conf

WORKDIR /var/www/html/MetGENE
COPY . /var/www/html/MetGENE

RUN mkdir -p /var/www/html/MetGENE/cache \
    && chown -R www-data:www-data /var/www/html/MetGENE/cache \
    && chmod -R 775 /var/www/html/MetGENE/cache

RUN Rscript -e "if (!requireNamespace('BiocManager', quietly = TRUE)) install.packages('BiocManager', repos='https://cloud.r-project.org')" \
    && Rscript -e "BiocManager::install('KEGGREST', ask = FALSE, update = FALSE)" \
    && Rscript -e "install.packages(c('textutils', 'tidyjson', 'tictoc'), repos='https://cloud.r-project.org')" \
    && Rscript -e "stopifnot(all(c('KEGGREST', 'textutils', 'tidyjson', 'tictoc') %in% rownames(installed.packages())))"

EXPOSE 80