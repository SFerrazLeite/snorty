node default {
  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }
  include stdlib

  class { 'java':
    distribution => 'jre',
  }

  # Elasticsearch
  class { 'elasticsearch':
    package_url => 'https://download.elasticsearch.org/elasticsearch/release/org/elasticsearch/distribution/deb/elasticsearch/2.1.1/elasticsearch-2.1.1.deb',
    config => { 'cluster.name' => 'snorty-kibana' },
    require => Class['java']
  }

  elasticsearch::instance { 'es-01':
    config => { 
      'cluster.name' => 'snorty-kibana',
      'index.number_of_replicas' => '0',
      'index.number_of_shards'   => '1',
      'network.host' => '0.0.0.0',
      'marvel.agent.enabled' => false #DISABLE marvel data collection. 
    },        # Configuration hash
    init_defaults => { }, # Init defaults hash
    require => [
      Class['java'],
      Class['elasticsearch']
    ],
    before => Class['::kibana4']
  }

  class { '::kibana4':
    package_ensure    => '4.3.0-linux-x64',
    package_provider  => 'archive',
    symlink           => true,
    manage_user       => true,
    kibana4_user      => kibana4,
    kibana4_group     => kibana4,
    kibana4_gid       => 200,
    kibana4_uid       => 200,
    config            => {
      'server.port'           => 5601,
      'server.host'           => '0.0.0.0',
      'elasticsearch.url'     => 'http://localhost:9200',
    }
  }
}
