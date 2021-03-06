#!/bin/bash
# overwrite proxy if it is present in /etc/proxy
if [ -f /etc/proxy/proxy ]; then
    mkdir -p /data/srv/state/das/proxy
    ln -s /etc/proxy/proxy /data/srv/state/das/proxy/proxy.cert
    mkdir -p /data/srv/current/auth/proxy
    ln -s /etc/proxy/proxy /data/srv/current/auth/proxy/proxy
fi

# use service configuration files from /etc/secrets if they are present
cdir=/data/srv/current/config/das
files=`ls $cdir`
for fname in $files; do
    if [ -f /etc/secrets/$fname ]; then
        if [ -f $cdir/$fname ]; then
            rm $cdir/$fname
        fi
        ln -s /etc/secrets/$fname $cdir/$fname
    fi
done

# start mongodb
mongod --config $WDIR/mongodb.conf
# upload DASMaps into MongoDB
das_js_import /data/DASMaps/js

# start monitoring
if [ -f /data/monitor.sh ]; then
    /data/monitor.sh
fi

# start das2go server
if [ -f /etc/secrets/dasconfig.json ]; then
    das2go_monitor -config /etc/secrets/dasconfig.json
else
    das2go_monitor -config $GOPATH/src/github.com/dmwm/das2go/dasconfig.json
fi
