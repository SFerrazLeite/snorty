#!/bin/bash
FILE="/etc/apt/sources.list.d/puppet.list"
if [ -f "$FILE" ]
then
    echo "Puppet already up to date - skipping"
else
    wget https://apt.puppetlabs.com/puppetlabs-release-pc1-trusty.deb
    sudo dpkg -i puppetlabs-release-pc1-trusty.deb
    sudo sh -c 'echo "deb http://apt.puppetlabs.com// trusty main" >> /etc/apt/sources.list.d/puppet.list'
    sudo apt-get update
    sudo puppet resource package puppet ensure=latest
    export LC_CTYPE=en_US.UTF-8
    sudo gem install r10k
fi

