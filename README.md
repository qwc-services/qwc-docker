Docker containers qwc-server
============================

Docker installation
-------------------

* https://docs.docker.com/engine/installation/linux/ubuntu/

* docker-compose (https://docs.docker.com/compose/install/):
    
```
dockerComposeVersion=1.21.2
curl -L https://github.com/docker/compose/releases/download/$dockerComposeVersion/docker-compose-`uname -s`-`uname -m` > ~/bin/docker-compose
chmod +x ~/bin/docker-compose
```


Setup
-----

Setup docker-compose configuration from example:

    cp docker-compose-example.yml docker-compose.yml

Copy additional fonts for QGIS Server. Example:

    unzip /tmp/frutiger_ltcom55.zip -d qgis-server/fonts/

Copy QWC2 files from a production build (see [QWC2 Quick start](https://github.com/qgis/qwc2-demo-app/blob/master/doc/QWC2_Documentation.md#quick-start)):

    SRCDIR=path/to/qwc2-app/prod/ DSTDIR=$PWD/volumes
    cd $SRCDIR && \
    cp -r assets $DSTDIR/qwc2 && \
    cp -r translations $DSTDIR/qwc2 && \
    cp dist/QWC2App.js $DSTDIR/qwc2/dist/ && \
    cp index.html $DSTDIR/qwc2/ && \
    sed -e '/proxyServiceUrl/d' \
      -e 's!permalinkServiceUrl":\s*".*"!permalinkServiceUrl": "/permalink"!' \
      -e 's!elevationServiceUrl":\s*".*"!elevationServiceUrl": "/elevation"!' \
      -e 's!searchServiceUrl":\s*".*"!searchServiceUrl": "/search"!' \
      -e 's!editServiceUrl":\s*".*"!editServiceUrl": "/data"!' \
      -e 's!authServiceUrl":\s*".*"!authServiceUrl": "/auth"!' \
      -e 's!mapInfoService":\s*".*"!mapInfoService": "/mapinfo"!' \
      -e 's!featureReportService":\s*".*"!featureReportService": "/document"!' \
      -e 's!{"key": "Login", "icon": "img/login.svg"}!{{ login_logout_item }}!g' \
      config.json > $DSTDIR/qwc2/config.json && \
    cd -

Copy QWC2 themes config file from example:

    cp volumes/qwc2/themesConfig-example.json volumes/qwc2/themesConfig.json

Container Build:

    docker-compose build

**NOTE:** Building the PostGIS container overwrites its database

Setup PostgreSQL connection service file `~/.pg_service.conf` 
for DB connections to PostGIS container:

```
cat >>~/.pg_service.conf <<EOS
[qwc_configdb]
host=localhost
port=5439
dbname=qwc_demo
user=qwc_admin
password=qwc_admin
sslmode=disable

[qwc_geodb]
host=localhost
port=5439
dbname=qwc_demo
user=qwc_service_write
password=qwc_service_write
sslmode=disable

[qwc_webmapping]
host=localhost
port=5439
dbname=qwc_demo
user=qgis_server
password=qgis_server
sslmode=disable
EOS
```


Usage
-----

Start all containers:

    docker-compose up -d

Follow log output:

    docker-compose logs -f

Open map viewer:

    http://localhost:8088/

Connect to config DB:

    psql "service=qwc_configdb"

Stop all containers:

    docker-compose down

Update service containers to latest versions from Git:

```
CONTAINERS="qwc-admin-gui qwc-config-service qwc-data-service qwc-map-viewer qwc-ogc-service"
for ctr in $CONTAINERS; do
  git_version=$(git ls-remote https://github.com/qwc-services/$ctr HEAD | cut -f 1)
  docker-compose build --build-arg GIT_VERSION=$git_version $ctr
done
```

Update authentication service:
```
AUTH_SERVICE=qwc-db-auth
git_version=$(git ls-remote https://github.com/qwc-services/$AUTH_SERVICE HEAD | cut -f 1)
docker-compose build --build-arg GIT_VERSION=$git_version qwc-auth-service
```

Update PostGIS container to ConfigDB migration `ALEMBIC_VERSION` (**NOTE**: Overwrites current database):

    docker-compose build --build-arg ALEMBIC_VERSION=217f272b9c26 qwc-postgis
