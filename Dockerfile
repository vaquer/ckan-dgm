# mxabierto CKAN
# Base mxabierto/ckan installation
# Heavily based on datacats ( https://github.com/datacats/datacats )
# Build:
#   docker build -t mxabierto/ckan .
# Usage:
#   docker run --rm -itP mxabierto/ckan

# Base image
FROM mxabierto/ckan
MAINTAINER Francisco Vaquero <francisco@opi.la>

# Instalacion de los plugins
# Agregar tantos como sea necesario siguiendo la estructura:
# $CKAN_HOME/bin/pip install -e git+https:repo
RUN \
  virtualenv $CKAN_HOME && \
  $CKAN_HOME/bin/pip install -e git+https://github.com/ckan/ckanext-spatial.git@stable#egg=ckanext-spatial && \
  $CKAN_HOME/bin/pip install -r $CKAN_HOME/src/ckanext-spatial/pip-requirements.txt && \
  $CKAN_HOME/bin/pip install -e git+https://github.com/opintel/ckanext-more-facets.git@test-category#egg=ckanext-more-facets && \
  $CKAN_HOME/bin/pip install -e git+https://github.com/ckan/ckanext-googleanalytics.git#egg=ckanext-googleanalytics && \
  $CKAN_HOME/bin/pip install -e git+https://github.com/ckan/ckanext-dcat.git#egg=ckanext-dcat && \
  $CKAN_HOME/bin/pip install -r $CKAN_HOME/src/ckanext-dcat/requirements.txt && \
  $CKAN_HOME/bin/pip install -e git+https://github.com/okfn/ckanext-disqus#egg=ckanext-disqus && \
  $CKAN_HOME/bin/pip install -e git+https://github.com/opintel/ckanext-mxtheme.git#egg=ckanext-mxtheme && \
  $CKAN_HOME/bin/pip install -e git+https://github.com/opintel/CKAN_Calidad.git#egg=ckanext-mxopeness&subdirectory=ckanext-mxopeness && \
  $CKAN_HOME/bin/pip install -e git+https://github.com/vaquer/ckanext-harvest@dkan#egg=ckanext-harvest && \
  $CKAN_HOME/bin/pip install -e git+https://github.com/vaquer/ckanext-dkan#egg=ckanext-dkan && \
  $CKAN_HOME/bin/pip install -r $CKAN_HOME/src/ckanext-harvest/pip-requirements.txt


# Create storage volumen folder 
RUN mkdir -p /var/lib/ckan/storage/uploads/group && \
  find /var/lib/ckan/storage -type d -exec chmod 777 {} \;

RUN mkdir -p /var/lib/ckan/resources/ && \
  find /var/lib/ckan/resources -type d -exec chmod 777 {} \;


# Add my configuration file
ADD develop.ini /project/development.ini
ADD start.sh /start.sh

# Replace apache config for base url  /busca
ADD ckan_default.conf /etc/apache2/sites-available/ckan_default.conf

ENTRYPOINT ["/start.sh"]
