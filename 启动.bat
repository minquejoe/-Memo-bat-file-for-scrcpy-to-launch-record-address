@echo off
setlocal enabledelayedexpansion

:: Initialize an empty array
set i=0
for /L %%x in (1, 1, 5) do (
    set "ip[%%x]="
    set "port[%%x]="
)

:: Check if the file exists
if exist last_used.txt (
    :: Read the file and set the variables
    for /F "tokens=1,2 delims=," %%a in (last_used.txt) do (
        set /a i+=1
        set "ip[!i!]=%%a"
        set "port[!i!]=%%b"
    )
)

:: Display the last 5 IP and port combinations
echo Last 5 IP and Port combinations:
for /L %%x in (1, 1, 5) do (
    echo %%x. !ip[%%x]!:!port[%%x]!
)

:: Prompt for IP and PORT
set /p choice=Enter a number between 1 and 5 to use the corresponding IP and Port, or enter 0 to input a new IP and Port: 
if "!choice!"=="0" (
    set /p new_ip=Enter new IP address: 
    set /p new_port=Enter new port number: 
) else (
    set new_ip=!ip[%choice%]!
    set new_port=!port[%choice%]!
)

:: Check if the new IP and PORT already exist in the array
set "exists=0"
for /L %%x in (1, 1, 5) do (
    if "!ip[%%x]!"=="!new_ip!" if "!port[%%x]!"=="!new_port!" (
        echo The IP and Port combination already exists.
        set "exists=1"
    )
)

:: If the new IP and PORT do not exist in the array, shift the IP and PORT arrays and add the new IP and PORT to the end
if "!exists!"=="0" (
    for /L %%x in (4, -1, 1) do (
        if defined ip[%%x] (
            set /a next=%%x+1
            set "ip[!next!]=!ip[%%x]!"
            set "port[!next!]=!port[%%x]!"
        )
    )
    set "ip[1]=!new_ip!"
    set "port[1]=!new_port!"

    :: Save the IP and PORT to the file
    >last_used.txt (
        for /L %%x in (1, 1, 5) do (
            if defined ip[%%x] (
                echo !ip[%%x]!,!port[%%x]!
            )
        )
    )
)

:: Get the device name
for /f "delims=" %%a in ('adb -s !new_ip!:!new_port! shell getprop ro.product.model') do set "device=%%a"
echo =========Device Name: %device%=========

:: Start the loop
:: --window-width=453 --window-height=1005
:: --window-width=1450 --window-height=815

:loop
    if "!device!"=="SHARK KLE-A0" (
        echo wait for a while ... ...
        adb -s !new_ip!:!new_port! shell input keyevent 26
        ping -n 6 127.0.0.1 > nul
        adb -s !new_ip!:!new_port! shell input tap 540 2000
        adb -s !new_ip!:!new_port! shell input swipe 540 2000 540 500 1000
        scrcpy --video-bit-rate=128M --tcpip=!new_ip!:!new_port! --turn-screen-off --power-off-on-close
    ) else (
        scrcpy --video-bit-rate=128M --tcpip=!new_ip!:!new_port! 
    )
if %errorlevel% neq 0 goto loop
