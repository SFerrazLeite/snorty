node default {
  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }
  include stdlib

  exec { 'apt-get-update':  
    command     => '/usr/bin/apt-get update',
    refreshonly => true,
  }

  file { '/etc/snort/':
    ensure => 'directory',
    owner  => 'vagrant',
    group  => 'vagrant'
  }

  file { '/etc/snort/snort.conf':
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0666',
    source  => 'puppet:///modules/snorty/snort.conf',
    require => File['/etc/snort/']
  }    

  package { 'snort':
    ensure  => installed,
    require => [
      Exec['apt-get-update'],
      File['/etc/snort/snort.conf']
    ]
  }
  
  file { '/etc/snort/install-barnyard.sh':
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0766',
    require => File['/etc/snort/']
  }

}
