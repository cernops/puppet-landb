class landb::client {
    package{"rubygem-savon":
      provider    => 'yum',
      ensure      => 'latest',
    }   

    package{"rubygem-landb":
      provider    => 'yum',
      ensure      => 'latest',
    }   

    file{'/etc/puppet/landb_config.yaml':
      ensure  => file, 
      content => template('landb/landb_config.yaml.erb'),
      owner   => root,
      group   => root,
      mode    => 0644,
      replace => true
    }  
} 
