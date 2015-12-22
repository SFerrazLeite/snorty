#!/bin/bash
FILE="/usr/src/install_barnyard_done"
if [ -f "$FILE" ]
then
    echo "barnyard already installed - skipping"
else
    apt-get install autoconf
    apt-get install libtool
    apt-get install libpcap0.8-dev
    apt-get install libdumbnet-dev
    apt-get install libdaq-dev
    apt-get install libmysqlclient-dev
    ln -s /usr/include/dumbnet.h /usr/include/dnet.h
    ldconfig
    cd /usr/src
    wget https://github.com/firnsy/barnyard2/tarball/master
    tar -zxf master
    cd firnsy-barnyard2*
    autoreconf -fvi -I ./m4
    ./configure --with-mysql --with-mysql-libraries=/usr/lib/x86_64-linux-gnu
    make
    make install
    mkdir /var/log/barnyard2
    touch "$FILE"
fi
