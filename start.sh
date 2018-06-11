#!/bin/sh

# Adjust config file
sed -i -e "s|#solr_url = http://127.0.0.1:8983/solr|solr_url = http://$SOLR_PORT_8080_TCP_ADDR:$SOLR_PORT_8080_TCP_PORT/solr|" /project/development.ini
sed -i -e "s|ckan.site_url =|ckan.site_url = $CKAN_SITE_URL|" /project/development.ini
sed -i -e "s|ckan_default:pass@localhost/ckan_default|$POSTGRES_ENV_POSTGRES_USER:$POSTGRES_ENV_POSTGRES_PASSWORD@$POSTGRES_PORT_5432_TCP_ADDR/$POSTGRES_ENV_POSTGRES_DB|" /project/development.ini
sed -i -e "s|ckan.root_path = {{LANG}}/|ckan.root_path = /$CKAN_ROOT_PATH/{{LANG}}/|" /project/development.ini

# Datapusher Configs
sed -i -e "s|datastore_default:pass@localhost/datastore_default|$DATASTORE_ENV_USER_DATASTORE:$DATASTORE_ENV_USER_DATASTORE_PWD@$DATASTORE_PORT_5432_TCP_ADDR/$DATASTORE_ENV_DATABASE_DATASTORE|" /project/development.ini
sed -i -e "s|datastore_default_read:pass@localhost/datastore_default|$DATASTORE_ENV_USER_DATASTORE_READ:$DATASTORE_ENV_USER_DATASTORE_PWD@$DATASTORE_PORT_5432_TCP_ADDR/$DATASTORE_ENV_DATABASE_DATASTORE|" /project/development.ini
sed -i -e "s|ckan.datapusher.url = http://0.0.0.0:8800/|ckan.datapusher.url = $DATAPUSHER_URL_WITH_PORT|" /project/development.ini

sed -i -e "s|hostname:port:database:username:password|$POSTGRES_PORT_5432_TCP_ADDR:5432:$POSTGRES_ENV_POSTGRES_DB:$POSTGRES_ENV_POSTGRES_USER:$POSTGRES_ENV_POSTGRES_PASSWORD|" /root/.pgpass
# Rabbit Configs
sed -i -e "s|ckan.harvest.mq.hostname = hostharvest|ckan.harvest.mq.hostname = $RABBIT_HOSTNAME|" /project/development.ini
sed -i -e "s|ckan.harvest.mq.port = 5672|ckan.harvest.mq.port = $RABBIT_PORT|" /project/development.ini
sed -i -e "s|ckan.harvest.mq.user_id = guest|ckan.harvest.mq.user_id = $RABBIT_USER|" /project/development.ini
sed -i -e "s|ckan.harvest.mq.password = guest|ckan.harvest.mq.password = $RABBIT_PASSWORD|" /project/development.ini
sed -i -e "s|ckan.harvest.mq.virtual_host = /|ckan.harvest.mq.virtual_host = $RABBIT_VHOST|" /project/development.ini

sed -i -e "s|mxtheme.adela_api_endopint =|mxtheme.adela_api_endopint = $ADELA_ENDPOINT|" /project/development.ini
sed -i -e "s|ckan.redis.url = redis://localhost:6379/0|ckan.redis.url = redis://$REDIS_IP:$REDIS_PORT/0|" /project/development.ini
# $CKAN_HOME/bin/paster --plugin=ckan datastore set-permissions -c /project/development.ini

# Create tables
if [ "$INIT_DBS" = true ]; then
  $CKAN_HOME/bin/paster --plugin=ckan db init -c /project/development.ini
  # $CKAN_HOME/bin/paster --plugin=ckanext-spatial spatial initdb 4326 -c /project/development.ini
fi

if [ "$INIT_DATSTORE" = true ]; then
  echo "Corre Datastore"
  $CKAN_HOME/bin/paster --plugin=ckan datastore set-permissions -c /project/development.ini | psql -h $POSTGRES_PORT_5432_TCP_ADDR -U $POSTGRES_ENV_POSTGRES_USER -w --set ON_ERROR_STOP=1
fi
# if [ "$INIT_HARVEST" = true ]; then
    # $CKAN_HOME/bin/paster --plugin=ckanext-harvest harvester initdb -c /project/development.ini
# fi
# Load a dump file to ckan database
# Temporalmente deshabilitado para probar el dump

#if [ "$LOAD_DUMP" == true]; then
#  wget /project/dump_ckan.sql $URL_POSTGRES_DUMP
#  $CKAN_HOME/bin/paster --plugin=ckan db clean -c /project/development.ini
#  $CKAN_HOME/bin/paster --plugin=ckan db load -c /project/development.ini /project/dump_ckan.sql
#fi

# Create test data for development purpose
if [ "$TEST_DATA" = true ]; then
  $CKAN_HOME/bin/paster --plugin=ckan create-test-data -c /project/development.ini echo "Llenando datos de prueba"
fi

# sudo touch /var/run/supervisor.sock
# sudo chmod 777 /var/run/supervisor.sock
# sudo service supervisor restart

# sudo supervisorctl reread
#sudo supervisorctl add ckan_gather_consumer
#sudo supervisorctl add ckan_fetch_consumer
#sudo supervisorctl add ckan_harvest
#sudo supervisorctl start ckan_gather_consumer
#sudo supervisorctl start ckan_fetch_consumer
#sudo supervisorctl start ckan_harvest

# Serve site
exec apachectl -DFOREGROUND 
