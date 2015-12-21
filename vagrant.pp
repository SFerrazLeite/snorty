node default {
  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }
  include stdlib

  exec { 'apt-get-update':  
    command     => '/usr/bin/apt-get update',
    refreshonly => true,
  }

  package { 'snort':
    ensure => installed,
    require => Exec['apt-get-update']
  }



}
