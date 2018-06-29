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


Usage
-----

Start all containers:

    docker-compose up -d

Follow log output:

    docker-compose logs -f

Open map viewer:

    http://localhost:8088/

Alle Container beenden:

    docker-compose down
