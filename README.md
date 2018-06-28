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
