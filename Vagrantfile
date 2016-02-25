# -*- mode: ruby -*-
# vi: set ft=ruby :

FileUtils.mkdir_p './modules'

Vagrant.require_version '>=1.6.0'

module_name = "snorty"
facts       = {
}

hostname    = "snorty-service"

Vagrant.configure("2") do |config|
    config.vm.box     = "ubuntu/trusty64"

    config.vm.provision :shell do |s|
        s.privileged = false
        s.inline = "sudo sed -i '/tty/!s/mesg n/tty -s \\&\\& mesg n/' /root/.profile"
    end

    config.vm.provision :shell, path: "bootstrap-puppet.sh"

    config.vm.provision :shell do |s|
        s.inline = "cd /vagrant && r10k -v info puppetfile install 2>&1"
    end

    config.vm.synced_folder ".", "/etc/puppet/modules/#{module_name}"
    config.vm.synced_folder ".", "/vagrant", disabled: false

    config.vm.define :snorty do |snorty|
        snorty.vm.hostname = "snorty-service"
        snorty.vm.network "private_network", ip: "192.168.13.15"

        snorty.vm.provision :puppet do |puppet|
          puppet.manifests_path = "."
          puppet.manifest_file  = "vagrant-snort.pp"
          puppet.options        = ["--verbose", "--hiera_config=/vagrant/hiera.yaml", '--modulepath=/etc/puppet/modules:/vagrant/modules']
          puppet.facter         = facts
        end
    end

    config.vm.define :kibana do |kibana|
        kibana.vm.hostname = "snorty-kibana"
        kibana.vm.network "private_network", ip: "192.168.13.16"
        kibana.vm.network :forwarded_port, guest: 9200, host: 9200
        kibana.vm.network :forwarded_port, guest: 9300, host: 9300
        kibana.vm.network :forwarded_port, guest: 5601, host: 5601

        kibana.vm.provision :puppet do |puppet|
          puppet.manifests_path = "."
          puppet.manifest_file  = "vagrant-kibana.pp"
          puppet.options        = ["--verbose", "--hiera_config=/vagrant/hiera.yaml", '--modulepath=/etc/puppet/modules:/vagrant/modules']
          puppet.facter         = facts
        end
    end

    config.vm.provider "virtualbox" do |vbox|
      vbox.gui = false
      vbox.memory = 1024
      vbox.customize ["modifyvm", :id, "--cpus", "2"]
      vbox.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    end
end
