This readme describes how to render osm based vector planet.osm files to raster images. Please note we will use china.osm.bz2 (which is a cut down version of planet.osm) for this wiki, as planet.osm is too huge for everything to be done in a timely manner.

Mapnik on Ubuntu 
--------------------------
* installation https://github.com/mapnik/mapnik/wiki/UbuntuInstallation
* mapnik original git `git clone https://github.com/mapnik/mapnik.git mapnik-git`
* rendering utils (for raster map/tiles) `svn co http://svn.openstreetmap.org/applications/rendering/mapnik/ mapnik-render`

on ubuntu 12.04 do:

    sudo apt-get install -y python-software-properties
    sudo add-apt-repository -y ppa:mapnik/v2.2.0
    sudo apt-get update && sudo apt-get -y install libmapnik mapnik-utils python-mapnik

Postgis Installation Guide
---------------------------------------------------
http://wiki.openstreetmap.org/wiki/Mapnik/PostGIS

on ubuntu 12.04 do: (add `c2h2` as the user and `china` as the database)

    sudo apt-get install -y postgresql-9.1-postgis postgresql-contrib-9.1
    sudo -u postgres -i -H
    createuser -SdR c2h2
    createdb -E UTF8 -O c2h2 china
    psql -d china -f /usr/share/postgresql/9.1/contrib/postgis-1.5/postgis.sql
    psql -d china -f /usr/share/postgresql/9.1/contrib/postgis-1.5/spatial_ref_sys.sql
    psql china -c "ALTER TABLE geometry_columns OWNER TO c2h2"
    psql china -c "ALTER TABLE spatial_ref_sys OWNER TO c2h2"
    exit  

edit postgres ACL: (change `md5` -> `trust`, and `peer` -> `trust` for local)

    sudo vim /etc/postgresql/9.1/main/pg_hba.conf 
    sudo /etc/init.d/postgresql restart 

to drop the db and re-import data:

    sudo -u postgres -i -H
    dropdb 'china'
    createdb -E UTF8 -O c2h2 china
    psql -d china -f /usr/share/postgresql/9.1/contrib/postgis-1.5/postgis.sql
    psql -d china -f /usr/share/postgresql/9.1/contrib/postgis-1.5/spatial_ref_sys.sql
    psql china -c "ALTER TABLE geometry_columns OWNER TO c2h2"
    psql china -c "ALTER TABLE spatial_ref_sys OWNER TO c2h2"
    exit

Install osm2pgsql (the osm -> postgis converting tool)
------------------------------------------------------------------------------------

Strongly recommand to install by using this ppa repo:

    sudo add-apt-repository -y ppa:kakrueger/openstreetmap
    sudo apt-get update && sudo apt-get install -y osm2pgsql

native apt-get is doable but might have some problems, and old, might have also bugs: (not suggested using below)

to fix osm2pgsql bug: (according to: http://lists.openstreetmap.org/pipermail/dev/2011-June/022995.html) (a style missing error)

    sudo  cp /usr/share/osm2pgsql/default.style /usr/share/

Load maps into postgis
----------------------------------

on ubuntu 12.04 do: (note this gonna dl 96mb~(2013.06) file and take approx 10-15min to import into postgis)

    wget -O china-latest.osm.pbf http://download.geofabrik.de/asia/china-latest.osm.pbf 
    osm2pgsql -d china -U c2h2 --slim -C 2000 china-latest.osm.pbf


Render our tiles with mapnik + python
-------------------------------------------------------
Now we generate our tiles with 4 theads:

Clone our git: (copied from http://svn.openstreetmap.org/applications/rendering/mapnik/)

    svn co http://svn.openstreetmap.org/applications/rendering/mapnik/ 
    cd mapnik-render
    ./get-coastline.sh
    python generate_xml.py osm.xml c2h2_china.xml  --password '' --host 'localhost' --user 'c2h2' --dbname 'china' --port '5432'
    git clone https://github.com/c2h2/osm_gen_tiles.git
    cd osm_gen_tils
    python gen_china_multi.py c2h2.xml


Delete empty file:  
-------------------------------------------------------    
     find . -size 103c -exec rm -rf {} \;(......)

    
wait .... and done!

Other rendering map/tiles
-----------------------------------------------
* Render with Postgis: http://svn.openstreetmap.org/applications/rendering/mapnik/README
* Direct Render Based On Mapnik : http://wiki.openstreetmap.org/wiki/Mapnik:_Rendering_OSM_XML_data_directly
* Styling change: use Tilemill http://mapbox.com/tilemill/
* Tiles in a single file: MBTiles: http://mapbox.com/developers/mbtiles/
* 

Tile Server Guide  (this is AIO package, and not very well tested by author of this wiki)
---------------------------------------------------------------------------------------------------------------------------------------
You will want this if you are building a tile server in one go.

http://switch2osm.org/serving-tiles/building-a-tile-server-from-packages/

Tilestache Guide
------------------------
https://github.com/migurski/TileStache

guide to install deps: http://obroll.com/install-python-pil-python-image-library-on-ubuntu-11-10-oneiric/

    git clone https://github.com/migurski/TileStache.git
    sudo apt-get install libjpeg8 libjpeg62-dev libfreetype6 libfreetype6-dev python2.7-dev
    sudo ln -s /usr/lib/x86_64-linux-gnu/libjpeg.so /usr/lib
    sudo ln -s /usr/lib/x86_64-linux-gnu/libfreetype.so /usr/lib
    sudo ln -s /usr/lib/x86_64-linux-gnu/libz.so /usr/lib
    sudo pip install -U PIL modestmaps simplejson werkzeug
    cd TileStashe
    python scripts/tilestache-server.py


If you still have problem with PIL
    
    wget http://effbot.org/downloads/Imaging-1.1.7.tar.gz
    cd Imaging-1.1.7 && python setup.py

Other Map Sources (cut down versions)
-----------------------------------------------
* http://downloads.cloudmade.com/asia/eastern_asia/china#downloads_breadcrumbs
* http://download.geofabrik.de/osm/


Good Reading Sources + Refs
----------------------------------
* a good index page: http://stackoverflow.com/questions/11321718/how-can-i-display-osm-tiles-using-python
* http://tilestache.org/
* OSM feature: http://wiki.openstreetmap.org/wiki/Zh-hans:Map_Features

Other Postgress FAQ
--------------------------------
* Allowing remote postgres access: http://www.cyberciti.biz/tips/postgres-allow-remote-access-tcp-connection.html
* activerecord with postgres: http://craiccomputing.blogspot.com/2008/03/ruby-activerecord-and-postgresql.html

ALSO TO-READ to myself
----------------------
* http://wiki.openstreetmap.org/wiki/WikiProject_China_Railways
