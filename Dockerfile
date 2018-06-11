# mxabierto CKAN
# Base mxabierto/ckan installation
# Heavily based on datacats ( https://github.com/datacats/datacats )
# Build:
#   docker build -t mxabierto/ckan .
# Usage:
#   docker run --rm -itP mxabierto/ckan

# Base image
# FROM mxabierto/ckan:ed4df9e73f1d28cfa90712dabb0f8b604180ef93
#FROM mxabierto/ckan:2.5.3
FROM mxabierto/ckan:2.7
MAINTAINER Francisco Vaquero <francisco@opi.la>

ENV DATAPUSHER_HOME /usr/lib/ckan/datapusher


# Install datapusher and dependencies
# RUN mkdir $DATAPUSHER_HOME && virtualenv $DATAPUSHER_HOME && \
#     git clone --branch master https://github.com/ckan/datapusher /project/datapusher && \
#     $DATAPUSHER_HOME/bin/pip install packaging==16.8 appdirs==1.4.0 && \
#     $DATAPUSHER_HOME/bin/pip install -r /project/datapusher/requirements.txt && \
#     $DATAPUSHER_HOME/bin/pip install -e /project/datapusher

# # Copy datapusher config files
# ADD datapusher.conf /etc/apache2/sites-available/datapusher.conf
# ADD datapusher_settings.py /etc/ckan/datapusher_settings.py

# RUN cp /project/datapusher/deployment/datapusher.wsgi /etc/ckan/datapusher.wsgi

# # Apche's datapusher config
# RUN sh -c 'echo "NameVirtualHost *:8800" >> /etc/apache2/ports.conf'
# RUN sh -c 'echo "Listen 8800" >> /etc/apache2/ports.conf'
# RUN a2ensite datapusher

# EXPOSE 8800

# Instalacion de los plugins
# Agregar tantos como sea necesario siguiendo la estructura:
# $CKAN_HOME/bin/pip install -e git+https:repo
# RUN apt-get update && apt-get install -y supervisor cron

RUN \
  virtualenv $CKAN_HOME && \
  $CKAN_HOME/bin/pip install -U setuptools==31.0.0 && \
  $CKAN_HOME/bin/pip install -e git+https://github.com/mxabierto/ckanext-googleanalytics.git#egg=ckanext-googleanalytics && \
  $CKAN_HOME/bin/pip install -e git+https://github.com/mxabierto/ckanext-dcat#egg=ckanext-dcat && \
  $CKAN_HOME/bin/pip install -r $CKAN_HOME/src/ckanext-dcat/requirements.txt && \
  $CKAN_HOME/bin/pip install -e git+https://github.com/mxabierto/ckanext-more-facets.git@develop#egg=ckanext-more-facets && \
  $CKAN_HOME/bin/pip install -e git+https://github.com/mxabierto/ckanext-mxtheme@develop#egg=ckanext-mxtheme && \
  $CKAN_HOME/bin/pip install -r $CKAN_HOME/src/ckanext-mxtheme/dev-requirements.txt && \
  $CKAN_HOME/bin/pip install -e git+https://github.com/mxabierto/ckanext-mxopeness.git#egg=ckanext-mxopeness && \
  $CKAN_HOME/bin/pip install -e git+https://github.com/mxabierto/ckanext-sitemap.git#egg=ckanext-sitemap && \
  $CKAN_HOME/bin/pip install -e git+https://github.com/mxabierto/ckanext-dkan#egg=ckanext-dkan && \
  $CKAN_HOME/bin/pip install newrelic && \
  $CKAN_HOME/bin/pip install GeoAlchemy2 && \
  $CKAN_HOME/bin/pip freeze

# Create storage volumen folder
RUN mkdir -p /var/lib/ckan/storage/uploads

RUN mkdir -p /var/lib/ckan/storage/uploads/group && \
  find /var/lib/ckan/storage -type d -exec chmod 777 {} \;

RUN mkdir -p /var/lib/ckan/resources/ && \
  find /var/lib/ckan/resources -type d -exec chmod 777 {} \;

RUN find /project/ckan/ckan/public/base/i18n -type d -exec chmod 777 {} \;
RUN mkdir -p /var/log/ckan/std/

# Add my configuration file
# ADD ckan_harvesting.conf /etc/supervisor/conf.d/ckan_harvesting.conf
# ADD crontab /etc/cron.d/harvest-cron
# RUN chmod 0644 /etc/cron.d/harvest-cron
ADD develop.ini /project/development.ini
ADD start.sh /start.sh
ADD pgfile.pgpass /root/.pgpass
RUN chmod 0600 /root/.pgpass

# Replace apache config for base url  /busca
ADD ckan_default.conf /etc/apache2/sites-available/ckan_default.conf

ENTRYPOINT ["/start.sh"]
