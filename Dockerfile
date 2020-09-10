
# https://github.com/docker-library/wordpress/blob/b1127748deb2db34e9b1306489e24eb49720454f/php7.3/apache/Dockerfile
FROM wordpress:5.5.1-php7.3-apache

EXPOSE 8080

ARG DEBIAN_FRONTEND=noninteractive

# Use the PORT environment variable in Apache configuration files.

RUN sed -i 's/80/${PORT}/g' /etc/apache2/sites-available/000-default.conf /etc/apache2/ports.conf
ENV GOOGLE_APPLICATION_CREDENTIALS="/root/infinite-lens-273121-7f3a7181b815.json"

# Install system packages.

RUN apt-get update && apt-get install --assume-yes apt-utils
RUN apt-get -yq install net-tools wget curl gnupg2

# Install gcsfuse.
RUN echo "deb http://packages.cloud.google.com/apt gcsfuse-bionic main" | tee /etc/apt/sources.list.d/gcsfuse.list
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
RUN apt-get update
RUN apt-get install -y gcsfuse

# Install gcloud.
RUN apt-get install -y apt-transport-https
RUN apt-get install -y ca-certificates
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
RUN apt-get update
RUN apt-get install -y google-cloud-sdk

# Download and install cloud_sql_proxy
RUN wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -O /usr/local/bin/cloud_sql_proxy && \ 
    chmod +x /usr/local/bin/cloud_sql_proxy

# custom entrypoint
COPY wordpress/infinite-lens-273121-7f3a7181b815.json /root/


RUN gcloud auth activate-service-account --key-file=/root/infinite-lens-273121-7f3a7181b815.json
# RUN gcsfuse  --only-dir wordpress/wp-content test-wp-storage  /var/www/html/wp-content  

COPY wordpress/cloud-run-entrypoint.sh /usr/local/bin/
COPY wordpress/docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
# wordpress conf

COPY wordpress/wp-config.php /var/www/html/wp-config.php

#ENTRYPOINT ["cloud-run-entrypoint.sh","docker-entrypoint.sh"]
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["apache2-foreground"]