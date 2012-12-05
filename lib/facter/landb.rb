require 'yaml'
require 'landb'

class LandbWrapper
  attr_reader :client

  def initialize
    set_landb_config
    @client = landb_client
  end

  def set_landb_config
    config = begin
               YAML.load(File.open("/etc/puppet/landb_config.yaml"))
             rescue ArgumentError => e
               puts "Could not parse YAML: #{e.message}"
             end
    LandbClient.set_config(config)
  end

  def landb_client
    LandbClient.instance
  end

  def add_landb_location
    location = @client.get_my_device_info([]).device_info.location

    Facter.add("landb_location") do 
      setcode do 
        "#{location.building}-#{location.floor}-#{location.room}"
      end
    end         
  end

  def add_responsible_info
    responsible = @client.get_my_device_info([]).device_info.responsible_person

    Facter.add("landb_responsible_name") do 
      setcode do 
        "#{responsible.first_name} #{responsible.name}"
      end
    end          

    Facter.add("landb_responsible_email") do 
      setcode do 
        "#{responsible.email}"
      end
    end   
  end
end

facter_landb = LandbWrapper.new
if !facter_landb.nil?
  facter_landb.add_landb_location
  facter_landb.add_responsible_info
end
