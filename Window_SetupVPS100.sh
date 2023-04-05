@echo off
setlocal EnableDelayedExpansion

:random
set "rand="
set "chars=ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
for /L %%i in (1,1,5) do (
    set /A "idx=!RANDOM! %% 62"
    for %%j in (!idx!) do set "rand=!rand!!chars:~%%j,1!"
)
echo %rand%

set "array=1 2 3 4 5 6 7 8 9 0 a b c d e f"
for %%i in (%array%) do set "array[%%i]=%%i"

:gen64
set /A "rand=!RANDOM! %% 16"
set "ip64=!array[%rand%]!!array[!RANDOM! %% 16]!!array[!RANDOM! %% 16]!!array[!RANDOM! %% 16]"
echo %1:!ip64!:!ip64!:!ip64!:!ip64!

:install_3proxy
echo installing 3proxy
set "URL=https://raw.githubusercontent.com/FZF4R/Vultr-Proxy/master/3proxy-3proxy-0.8.6.tar.gz"
powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%URL%', '3proxy-3proxy-0.8.6.tar.gz')"
tar -zxvf 3proxy-3proxy-0.8.6.tar.gz
cd 3proxy-3proxy-0.8.6
make -f Makefile.Linux
mkdir -p C:\Program Files\3proxy\{bin,logs,stat}
copy src\3proxy.exe C:\Program Files\3proxy\bin
copy scripts\rc.d\proxy.bat C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\3proxy.bat
cd ..

:gen_3proxy
(
echo daemon
echo maxconn 1000
echo nscache 65536
echo timeouts 1 5 30 60 180 1800 15 60
echo setgid 65535
echo setuid 65535
echo flush
echo auth strong
echo.
for /f "usebackq delims=/" %%i in (`type %WORKDATA%`) do (
    set "user=%%i"
    set "pass=%%j"
    echo users !user!:CL:!pass!
)
echo.
for /f "usebackq delims=/" %%i in (`type %WORKDATA%`) do (
    set "user=%%i"
    echo auth strong
    echo allow !user!
    echo proxy -6 -n -a -p%%k -i%%j -e%%l
    echo flush
)
) > C:\Program Files\3proxy\3proxy.cfg

:gen_proxy_file_for_user
(
for /f "usebackq delims=/" %%i in (`type %WORKDATA%`) do (
    set "ip=%%j"
    set "port=%%k"
    set "user=%%i"
    set "pass=%%l"
    echo !ip!:!port!:!user!:!pass!
)
) > proxy.txt

rem :upload_proxy
rem set "pass=!random!"
rem powershell -Command "Compress-Archive -Path proxy.txt -DestinationPath proxy.zip -CompressionLevel Optimal -Password $pass"
rem powershell -Command "(New-Object System.Net.WebClient).UploadFile('https://transfer.sh/proxy.zip', 'PUT', 'proxy.zip')"
rem echo Proxy is ready!
