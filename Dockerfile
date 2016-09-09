# mxabierto CKAN
# Base mxabierto/ckan installation
# Heavily based on datacats ( https://github.com/datacats/datacats )
# Build:
#   docker build -t mxabierto/ckan .
# Usage:
#   docker run --rm -itP mxabierto/ckan

# Base image
FROM mxabierto/ckan:v2.0.5
MAINTAINER Francisco Vaquero <francisco@opi.la>

# Instalacion de los plugins
# Agregar tantos como sea necesario siguiendo la estructura:
# $CKAN_HOME/bin/pip install -e git+https:repo
RUN \
  virtualenv $CKAN_HOME && \
  $CKAN_HOME/bin/pip install -e git+https://github.com/opintel/ckanext-mxtheme.git#egg=ckanext-mxtheme && \
  git clone https://github.com/opintel/CKAN_Calidad.git $CKAN_HOME/src/ckanext-mxopeness && \
  cp -r $CKAN_HOME/src/ckanext-mxopeness/ckanext-mxopeness/* $CKAN_HOME/src/ckanext-mxopeness/ && \
  $CKAN_HOME/bin/python $CKAN_HOME/src/ckanext-mxopeness/setup.py develop && \
  $CKAN_HOME/bin/pip install -e git+https://github.com/ckan/ckanext-spatial.git@stable#egg=ckanext-spatial && \
  $CKAN_HOME/bin/pip install -r $CKAN_HOME/src/ckanext-spatial/pip-requirements.txt && \
  $CKAN_HOME/bin/pip install -e git+https://github.com/opintel/ckanext-more-facets.git@test-category#egg=ckanext-more-facets && \
  $CKAN_HOME/bin/pip install -e git+https://github.com/ckan/ckanext-googleanalytics.git#egg=ckanext-googleanalytics && \
  $CKAN_HOME/bin/pip install -e git+https://github.com/ckan/ckanext-dcat.git#egg=ckanext-dcat && \
  $CKAN_HOME/bin/pip install -r $CKAN_HOME/src/ckanext-dcat/requirements.txt && \
  $CKAN_HOME/bin/pip install -e git+https://github.com/okfn/ckanext-disqus#egg=ckanext-disqus
  #mv $CKAN_HOME/src/CKAN_Calidad/ckanext-mxopeness/ckanext-mxopeness/* $CKAN_HOME/src/ckanext-mxopeness && \

# Create storage volumen folder 
RUN mkdir -p /var/lib/ckan/storage

# Add my configuration file
ADD develop.ini /project/development.ini
ADD start.sh /start.sh

# Replace apache config for base url  /busca
ADD ckan_default.conf /etc/apache2/sites-available/ckan_default.conf

ENTRYPOINT ["/start.sh"]
