### CKAN PLUGINS
Dockerizacion de una instancia de CKAN + plugins para datos.gob.mx.

# Deployment Kubernetes
Para implementaciones basadas en kubernetes usar la siguiente plantilla.

```sh
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
 name: ckan
spec:
 replicas: 1
 template:
   metadata:
     labels:
       app: ckan
       tier: frontend
   spec:
     containers:
       - name: ckan
         image: mxabierto/ckan-dgm:v2.0.{version}
         ports:
           - containerPort: 5000
         env:
           - name: INIT_DBS
             value: "false"
           - name: CKAN_SITE_URL
             value: "http://datos.gob.mx"
           - name: SOLR_PORT_8080_TCP_ADDR
             value: "{xxxxxxx}"
           - name: SOLR_PORT_8080_TCP_PORT
             value: "{puerto-solr}"
           - name: POSTGRES_PORT_5432_TCP_ADDR
             value: "{xxxxxx}"
           - name: POSTGRES_PORT_5432_TCP_PORT
             value: "{puerto-postgres}"
           - name: POSTGRES_ENV_POSTGRES_DB
             value: "{ckan-databse}"
           - name: POSTGRES_ENV_POSTGRES_USER
             value: "{ckan-user}"
           - name: POSTGRES_ENV_USER_DATASTORE
             value: "{ckan-datastore-user}"
           - name: POSTGRES_ENV_POSTGRES_PASSWORD
             value: "{xxxxxx}"
           - name: POSTGRES_ENV_DATABASE_DATASTORE
             value: "{datastore-dbname}"
           - name: REDIS_PORT_6379_TCP_ADDR
           	 value: "{redis_tcp_ip}"
         volumeMounts:
           - mountPath: "/var/lib/ckan"
             name: ckan-data
     nodeSelector:
       name: worker-02
     volumes:
       - name: ckan-data
         hostPath:
           path: "xxxxxxxxxxxxxxxxx"
```

## Release Notes

- Cambio de nombre en variable de ambiente para SOLR (SOLR_PORT_8080_TCP_PORT, SOLR_PORT_8080_TCP_PORT)

- Dependencia con instancias REDIS para manejo de background-jobs (REDIS_PORT_6379_TCP_ADDR)