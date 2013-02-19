class landb::client {
    package{"rubygem-savon":
      ensure      => 'latest',
    }   

    package{"rubygem-landb":
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
