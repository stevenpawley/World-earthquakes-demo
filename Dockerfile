FROM rocker/r-base:4.3.0
RUN apt-get update -y && apt-get install -y  libicu-dev  make  libcurl4-openssl-dev libssl-dev  zlib1g-dev  libicu-dev make zlib1g-dev pandoc  libcurl4-openssl-dev libssl-dev make  make zlib1g-dev  libicu-dev make pandoc  libssl-dev  pandoc  libicu-dev libcurl4-openssl-dev libssl-dev zlib1g-dev make pandoc  libfreetype6-dev libfribidi-dev libharfbuzz-dev libfontconfig1-dev libjpeg-dev libpng-dev libtiff-dev  pandoc libicu-dev make  libicu-dev libcurl4-openssl-dev libssl-dev libxml2-dev  libicu-dev pandoc  libfontconfig1-dev libfreetype6-dev  libfreetype6-dev libfribidi-dev libharfbuzz-dev libfontconfig1-dev  libfreetype6-dev libfribidi-dev libharfbuzz-dev libfontconfig1-dev pandoc libicu-dev libcurl4-openssl-dev libssl-dev libjpeg-dev libpng-dev libtiff-dev zlib1g-dev make libxml2-dev  libxml2-dev && rm -rf /var/lib/apt/lists/*
RUN mkdir -p /usr/local/lib/R/etc/ /usr/lib/R/etc/
RUN echo "options(renv.config.pak.enabled = TRUE, repos = c(CRAN = 'https://cran.rstudio.com/'), download.file.method = 'libcurl', Ncpus = 4)" | tee /usr/local/lib/R/etc/Rprofile.site | tee /usr/lib/R/etc/Rprofile.site
RUN R -e 'install.packages(c("renv","remotes"))'
COPY renv.lock renv.lock
RUN R -e 'renv::restore()'
