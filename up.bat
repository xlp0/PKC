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
    )
)
echo Copy docker-compose.yml for localhost configuration
copy ".\config-template\docker-compose-local.yml" "docker-compose.yml"
echo Copy .env for localhost configuration
copy ".\config-template\.env-local" ".env"

if not exist ".\mountpoint.tar.gz" (
    echo Download mountpoint from pkc.pub
    powershell -Command "Invoke-WebRequest -Uri "http://res.pkc.pub/mountpoint-mac.tar.gz" -OutFile "./mountpoint.tar.gz""

)

if not exist ".\mountpoint" (
    echo Extracting mountpoint.tar.gz file
    tar -xzvf ./mountpoint.tar.gz
)

echo Bring PKC Container Services Up
docker-compose up -d
echo Wait for Docker-compose to get services ready before launching the browser... 
timeout /t %w% > nul
docker exec -it xlp_mediawiki php /var/www/html/maintenance/update.php --quick
start https://pkc.local
