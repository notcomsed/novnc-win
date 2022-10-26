::#!/usr/bin/env bash
@echo off
::# Copyright (C) 2018 The noVNC Authors
::# Licensed under MPL 2.0 or any later version (see LICENSE.txt)


set NAME=%0
set REAL_NAME="$(readlink -f $0)"
set HERE="$(cd "$(dirname "$REAL_NAME")" && pwd)"
set PORT=6080
set VNC_DEST=localhost:5900
set CERT=
set KEY=
set WEB=
set proxy_pid=
set SSLONLY=
set RECORD_ARG=
set SYSLOG_ARG=
set HEARTBEAT_ARG=
set IDLETIMEOUT_ARG=
set TIMEOUT_ARG=
set hostname=0.0.0.0

if "%1" == "" ( goto usage )
if "%1" == "-h" ( goto usage )
::# Process Arguments
::# Arguments that only apply to chrooter itself
::    --listen)  PORT="${OPTARG}"; shift            ;;
set PORT=%2
::    --vnc)     VNC_DEST="${OPTARG}"; shift        ;;
set VNC_DEST=%4
::    --cert)    CERT="${OPTARG}"; shift            ;;
::    --key)     KEY="${OPTARG}"; shift             ;;
::    --web)     WEB="${OPTARG}"; shift            ;;
 ::   --ssl-only) SSLONLY="--ssl-only"             ;;
 ::   --record) RECORD_ARG="--record ${OPTARG}"; shift ;;
 ::   --syslog) SYSLOG_ARG="--syslog ${OPTARG}"; shift ;;
 ::   --heartbeat) HEARTBEAT_ARG="--heartbeat ${OPTARG}"; shift ;;
 ::   --idle-timeout) IDLETIMEOUT_ARG="--idle-timeout ${OPTARG}"; shift ;;
 ::   --timeout) TIMEOUT_ARG="--timeout ${OPTARG}"; shift ;;
 set TIMEOUT_ARG=%6
 ::   -h --help usage                              ;;
 ::   - usage "Unknown chrooter option: ${param}" ;;                                   

::# Sanity checks
if not "%1" == "--listen" ( goto usage )
netstat -an|find "%port%"||goto turnon
	set msg="Port %port% in use. Try --listen PORT"
    goto die 
:turnon

::# Find vnc.html

if exist "%~dp0..\vnc.html" (
 set WEB="%~dp0.."
) else (
set msg="Could not find vnc.html"
goto die
  )
:finshed

::# Find self.pem

::if [ -n "${CERT}" ]; then
::    if [ ! -e "${CERT}" ]; then
::        die "Could not find ${CERT}"
::    fi
::elif [ -e "$(pwd)/self.pem" ]; then
::    CERT="$(pwd)/self.pem"
::elif [ -e "${HERE}/../self.pem" ]; then
::    CERT="${HERE}/../self.pem"
::elif [ -e "${HERE}/self.pem" ]; then
::    CERT="${HERE}/self.pem"
::else
::    echo "Warning: could not find self.pem"
::fi

::# Check key file
::if [ -n "${KEY}" ]; then
::   if [ ! -e "${KEY}" ]; then
::        die "Could not find ${KEY}"
::    fi
::fi

::# try to find websockify (prefer local, try global, then download local)
if exist "%~dp0websockify\run" (
   set WEBSOCKIFY="%~dp0websockify\run"
   )
    if "%WEBSOCKIFY%" == "" (
        echo "The path %~dp0websockify exists, but $WEBSOCKIFY either does not exist or is not executable."
        echo "If you intended to use an installed websockify package, please remove %~dp0websockify."
        goto end
		)

    echo "Using local websockify at %WEBSOCKIFY%"
	
	
::else
 ::   WEBSOCKIFY_FROMSYSTEM=$(which websockify 2>/dev/null)
 ::   WEBSOCKIFY_FROMSNAP=${HERE}/../usr/bin/python2-websockify
 ::   [ -f $WEBSOCKIFY_FROMSYSTEM ] && WEBSOCKIFY=$WEBSOCKIFY_FROMSYSTEM
  ::  [ -f $WEBSOCKIFY_FROMSNAP ] && WEBSOCKIFY=$WEBSOCKIFY_FROMSNAP

    if not exist "%~dp0websockify\websockify.py" (
        echo "No installed websockify, attempting to clone websockify..."
        ::WEBSOCKIFY=${HERE}/websockify/run
        echo git clone https://github.com/novnc/websockify %~dp0websockify
)
        ::if [[ ! -e $WEBSOCKIFY ]]; then
       ::     echo "Unable to locate ${HERE}/websockify/run after downloading"
       ::     exit 1
       :: fi

       :: echo "Using local websockify at $WEBSOCKIFY"
    ::else
    ::    echo "Using installed websockify at $WEBSOCKIFY"
  ::  fi
::fi

echo "Starting webserver and WebSockets proxy on port %PORT%"
::#${HERE}/websockify --web ${WEB} ${CERT:+--cert ${CERT}} ${PORT} ${VNC_DEST} &
cd %~dp0websockify 
start python -m websockify --web %WEB% %PORT% %VNC_DEST%
::proxy_pid="$!"
::timeout 1
::if ! ps -p ${proxy_pid} >/dev/null; then
::    proxy_pid=
::    echo "Failed to start WebSockets proxy"
::    exit 1
::fi
cd ..
::echo -e "\n\nNavigate to this URL:\n"
::if [ "x$SSLONLY" == "x" ]; then
    echo http://%hostname%:%PORT%/vnc.html?host=%hostname%^&port=%PORT%
::else
::    echo -e "    https://$(hostname):${PORT}/vnc.html?host=$(hostname)&port=${PORT}\n"
::fi

echo Press Ctrl-C to exit
goto end
::wait ${proxy_pid}
:usage
    echo "Usage: %NAME% [--listen PORT] [--vnc VNC_HOST:PORT] [--cert CERT] [--ssl-only]"
    echo ""
    echo "Starts the WebSockets proxy and a mini-webserver and "
    echo "provides a cut-and-paste URL to go to."
    echo ""
    echo "    --listen PORT         Port for proxy/webserver to listen on"
    echo "                          Default: 6080"
    echo "    --vnc VNC_HOST:PORT   VNC server host:port proxy target"
    echo "                          Default: localhost:5900"
    echo "    --cert CERT           Path to combined cert/key file, or just"     **this is delete on windows
    echo "                          the cert file if used with --key"
    echo "                          Default: self.pem"
    echo "    --key KEY             Path to key file, when not combined with cert"     **this is delete on windows
    echo "    --web WEB             Path to web files (e.g. vnc.html)"      **this is delete on windows
    echo "                          Default: ./"
    echo "    --ssl-only            Disable non-https connections."     **this is delete on windows
    echo "                                    "
    echo "    --record FILE         Record traffic to FILE.session.js"     **this is delete on windows
    echo "                                    "
    echo "    --syslog SERVER       Can be local socket such as /dev/log, or a UDP host:port pair."  **this is delete on windows
    echo "                                    "
    echo "    --heartbeat SEC       send a ping to the client every SEC seconds"   **this is delete on windows
    echo "    --timeout SEC         after SEC seconds exit when not connected"
    echo "    --idle-timeout SEC    server exits after SEC seconds if there are no"     **this is delete on windows
    echo "                          active connections"
    echo "     **must add --listen  --vnc **
    echo "      novnc_proxy --listen 8080 --vnc 127.0.0.1:5900
    goto end

:die
    echo %msg%
    goto end
:cleanup


:end