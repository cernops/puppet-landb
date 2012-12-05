require 'yaml'
require 'landb'

Facter.add("landb_location") do 
  setcode do 
    config = begin
               YAML.load(File.open("/etc/puppet/landb_config.yaml"))
             rescue ArgumentError => e
               puts "Could not parse YAML: #{e.message}"
             end

    LandbClient.set_config(config)
    client = LandbClient.instance
    location = client.get_my_device_info([]).device_info.location
    "#{location.building}-#{location.floor}-#{location.room}"
  end
end
