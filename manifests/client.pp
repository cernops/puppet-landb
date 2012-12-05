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
<<<<<<< HEAD
      ensure  => file,
      content => template('landb/landb_config.yaml'),
      owner   => root,
      group   => root,
      mode    => 0644,
      require  => File['/etc/puppet'],
    }  

    $hash = landb_func({
        "method"           => "get_my_device_info",
        "method_arguments" => "",
        "response_info"    => [["device_info", "location", "building"]],
                              [["device_info", "location", "floor"]], 
                              [["device_info", "location", "room"]]})

    notify { $hash: } 
=======
      ensure  => file, 
      content => template('landb/landb_config.yaml.erb'),
      owner   => root,
      group   => root,
      mode    => 0644,
      replace => true
    }  
>>>>>>> bafed135ac30a2a40358db1dc0efeb76b663a551
} 
