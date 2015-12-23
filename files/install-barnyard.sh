#!/bin/bash
FILE="/usr/src/install_barnyard_done"
if [ -f "$FILE" ]
then
    echo "barnyard already installed - skipping"
else
    cd /usr/src
    wget https://github.com/firnsy/barnyard2/tarball/master
    tar -zxf master
    cd firnsy-barnyard2*
    autoreconf -fvi -I ./m4
    ./configure --with-mysql --with-mysql-libraries=/usr/lib/x86_64-linux-gnu
    make
    make install
    mkdir /var/log/barnyard2
    cd /usr/share/oinkmaster
    bash -c "sudo ./create-sidmap.pl /etc/snort/rules > /etc/snort/sid-msg.map"
    touch "$FILE"
fi
