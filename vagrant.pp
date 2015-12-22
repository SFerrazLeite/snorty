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

  exec { 'install-barnyard':
    command => '/etc/snort/install-barnyard.sh',
    user    => 'root',
    group   => 'root',
    require => File['/etc/snort/install-barnyard.sh']
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
