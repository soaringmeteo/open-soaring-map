Open Soaring Map
================

Soaring oriented tile server, based on [osmhike](https://github.com/bmgru/osmhike-tileserver).

Goals:
- only show information relevant for soaring pilots (land type, contours, hillshade, peaks, main cities, cables)
- reproducible way to generate the tiles

## Requirements

Designed for Linux. 
The Docker infrastructure must be installed ( see mini-guide in tutorial  )
Optimized for 8GB memory. If you have only 4GB, modify dbconf/myconf.conf

People stuck on Windows, might try the WSL feature of Windows, which allows to run Linux inside Windows...
It has been tested on a 8GB memory Windows10 PC, allowing 4GB for WSL.

## Installation

Download the project from github as a .zip file, and unzip to your home directory

Rename it as you want:  (eg:   ~/myproject) , and (IMPORTANT) make all subdirectories accessible to everybody
```
chmod -R a+rX  ~/myproject 
```
IMPORTANT:  Check that your userid is 1000 ( because it is the one used by several docker containers )
<br>If not, make the project tree rw by everybody
```
chmod -R a+rwX  ~/myproject 
```

*Note: it is possible that if you don't create the project inside a home directory, then Docker might have trouble to do volume mappings...*

## Preparation

Notes:
- this installation contains OSM data for Andorra, to have a small working example

Go to project directory ( where file docker-compose-yml resides )

Build the Docker images
```
docker compose build
```

## Launching the demo based on Andorra data

Launch database in the background:
```
docker compose up -V -d db
```

Import the data:

Note that after this command, the db container will exit from its terminal. But it continues to work in background
```
docker compose up -V import
```

Generate peak isolations data and city isolations data (note the usage of RUN command with argument)

It will take many minutes, to download elevation data from Internet

```
docker compose run import isolations
docker compose run import city_isolations
```

Generate contours lines  ( note the usage of RUN command with argument )
```
docker compose run import contours
```
*Note: The download speed from viewfinderpanoramas may be incredibly slow at some moments. It seems it works better when Americans are spleeping...*

Generate hillshade  (note the usage of RUN command with argument)
```
docker compose run import hillshade
```

Launch the tiles web server. Note: the first time, it may spend many minutes to download shapefiles from Internet...
```
docker compose up -V kosmtik
```

Navigate in the map: open a browser on the below url, and move the map until you see Andorra
```
http://localhost:8888
```


To stop the tile server, just type CTRL/C in its window<br>
To stop the database, use: `docker compose stop db`

Note:
You can ommit "docker compose up db" 
It will be done silently when launching import or kosmtik
( but the first execution of "db" initializes the database, and  I prefer to see clearly what happens at that moment )

Note:
The -V option inside docker-compose up -V,  forces the container to start from a fresh new filesystem
It is useful when you stop/start the container several times

Note:
After many runs, the Docker system may be overloaded with obsolete stuff  (stopped containers ...)
This commands does some cleaning
```
docker system prune
```
 
## Export tiles as static images

Remove any previous export
```
rm -rf ./files/export
```

Export the whole world:

```
docker compose run --rm kosmtik export-tiles --minZoom 0 --maxZoom 10 --bounds=-180,-85,180,85
```

Then export the WRF domain at higher zoom levels:

```
docker compose run --rm kosmtik export-tiles --minZoom 11 --maxZoom 14 --bounds=-1,40.5,20.5,51
```

Tiles are in directory `./files/export`.

## Load data from another area

In file ".env" , modify the variables which define the files to use
( filenames are relative to subdirectory "files/myfiles" )
- AREAOSM : the name of the .osm.pbf  file
- AREAPOLY:  the name of the polygon file that define the area for which the import phase will download "elevation data"

The best place to find such data is 
- https://download.geofabrik.de/
- https://download.geofabrik.de/europe

Then run again import phases ( Caution! it will erase previous database )
```
docker compose up -V import
docker compose run import isolations
docker compose run import city_isolations
docker compose run import contours
docker compose run import hillshade
```

CAUTION ! "1 arc second" resolution is not available for all countries
( check https://viewfinderpanoramas.org/Coverage%20map%20viewfinderpanoramas_org1.htm )
In this case, you must modify a parameter in ".env" to switch to "3 seconds arc" resolution
```
AREAPOLYSOURCE=view3
```

## Hints ##


Execute psql to navigate into database
```
docker compose run import psql
```

Or, uncomment the port mapping in docker-compose.yml for the db container and restart it. Then, use your local client (e.g. pgadmin) to connect to database server, with the following parameters:
- host: localhost
- port: 5432
- database: osm
- user: postgres
- password: postgres