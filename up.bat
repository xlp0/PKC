@ECHO OFF
set w=5
set a=C
set b=:\Program Files\Docker
set l=(C D E F G H I J K L M N O P Q R S T U V W X Y Z)
::set b=:\Videos
set c=%a%%b%
echo Try to find %c%
set found=false

for %%d in %l% do (
    if exist "%%d%b%" (
        echo Found the file: %%d%b%
        set found=true
        echo Will first shutdown PKC related docker processes
        docker-compose down
        goto :checkMountPoint
    )
)
:checkMountPoint
if not exist ".\mountPoint" (
    echo Download mountpoint from pkc.pub
    Invoke-WebRequest -Uri "http://res.pkc.pub/mountpoint-mac.tar.gz" -OutFile "./mountpoint.tar.gz"

    echo Try to use the default Data Package in .\resources
    cd .\resources
    .\unzip mountPoint.zip -d ..\.
    cd ..
)

for %%d in %l% do (
    if exist "%%d%b%" (
        echo Found the file: %%d%b%, meaning that Docker should have been installed, and needs to be running in the background
        set found=true
        echo Will use docker-compose to launch PKC
        docker-compose up -d 
        echo Wait for Docker-compose to get services ready before launching the browser... 
        timeout /t %w% > nul
        goto :readyToLaunch
    ) 
)

if %found%==false (
    echo Please install Docker Desktop for Windows
    echo (You might not have it installed at the X:%b% directory)
    echo Docker Desktop for Windows can be found here:
    start https://www.docker.com/products/docker-desktop
)

:readyToLaunch
docker exec -it pkc-mediawiki php /var/www/html/maintenance/update.php

start https://pkc.local