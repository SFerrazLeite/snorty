node default {
  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }
  include stdlib

  class { '::mysql::server':
    root_password    => 'root',
    override_options => { 
      'mysqld' => { 'max_connections' => '1024' } 
    }
  }

  exec { 'apt-get-update':  
    command     => '/usr/bin/apt-get update',
    refreshonly => true,
  }

  file { '/etc/snort/':
    ensure => 'directory',
    owner  => 'vagrant',
    group  => 'vagrant'
  }

  file { '/etc/snort/rules/':
    ensure  => 'directory',
    owner   => 'vagrant',
    group   => 'vagrant',
    require => File['/etc/snort/']
  }

  file { '/etc/snort/snort.conf':
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0666',
    source  => 'puppet:///modules/snorty/snort.conf',
    require => File['/etc/snort/']
  }

  file { '/etc/snort/snort.debian.conf':
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0666',
    source  => 'puppet:///modules/snorty/snort.debian.conf',
    require => File['/etc/snort/']
  }

  file { '/etc/snort/rules/local.rules':
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0666',
    source  => 'puppet:///modules/snorty/local.rules',
    require => File['/etc/snort/rules/']
  }

  package { 'snort':
    ensure  => installed,
    require => [
      Exec['apt-get-update'],
      File['/etc/snort/snort.conf'],
      File['/etc/snort/snort.debian.conf'],
      File['/etc/snort/rules/local.rules']
    ]
  }

  file { '/etc/snort/barnyard2.conf':
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0666',
    source  => 'puppet:///modules/snorty/barnyard2.conf',
    require => File['/etc/snort/']
  }    
  
  file { '/etc/snort/install-barnyard.sh':
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0766',
    source  => 'puppet:///modules/snorty/install-barnyard.sh',
    require => [
      File['/etc/snort/'],
      File['/etc/snort/barnyard2.conf'],
      Class['::mysql::server']
    ]
  }

  # prequisite packages for barnyard
  package { 'autoconf':
    ensure  => installed
  }
  package { 'libtool':
    ensure  => installed
  }
  package { 'libpcap0.8-dev':
    ensure  => installed
  }
  package { 'libdumbnet-dev':
    ensure  => installed
  }
  package { 'libdaq-dev':
    ensure  => installed
  }
  package { 'libmysqlclient-dev':
    ensure  => installed
  }
  file { '/usr/include/dnet.h':
    ensure  => 'link',
    target  => '/usr/include/dumbnet.h',
    require => Package['libdumbnet-dev']
  }

  exec { 'install-barnyard':
    command => '/etc/snort/install-barnyard.sh',
    user    => 'root',
    group   => 'root',
    require => [
      File['/etc/snort/install-barnyard.sh'],
      Package['autoconf'],Package['libtool'],Package['libpcap0.8-dev'],
      Package['libdumbnet-dev'],Package['libdaq-dev'],Package['libmysqlclient-dev'],
      File['/usr/include/dnet.h']
    ]
  }

  file { '/etc/snort/create_snort_db.sql':
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0766',
    source  => 'puppet:///modules/snorty/create_snort_db.sql',
    require => Class['::mysql::server']
  }

  exec { 'create_snort_db':
    command => "/usr/bin/mysql -uroot -proot < /etc/snort/create_snort_db.sql",
    user    => 'root',
    group   => 'root',
    require => File['/etc/snort/create_snort_db.sql']
  }

}
