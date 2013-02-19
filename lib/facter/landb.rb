begin
require 'landb' 
require 'savon'
require 'time'

class LandbWrapper
  attr_reader :client, :device_info

  def initialize
    set_landb_config
    @client      = landb_client
    @device_info = client.get_my_device_info([]).device_info
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
    location = @device_info.location

    Facter.add("landb_location") do 
      setcode do 
        "#{location.building} #{location.floor}-#{location.room}"
      end
    end         

    "#{location.building} #{location.floor}-#{location.room}"
  end

  def add_rackname
    zone = @device_info.zone 

    Facter.add("landb_rackname") do
      setcode do
        "#{zone}"
      end
    end

    "#{zone}"
  end

  def add_responsible_email
    responsible = @device_info.responsible_person

    Facter.add("landb_responsible_email") do 
      setcode do 
        "#{responsible.email}"
      end
    end  

    "#{responsible.email}"
  end

  def add_responsible_name
    responsible = @device_info.responsible_person

    Facter.add("landb_responsible_name") do 
      setcode do 
        "#{responsible.first_name} #{responsible.name}"
      end
    end          
     
    "#{responsible.first_name} #{responsible.name}"
  end

  def add_network_domain
    interfaces = @device_info.interfaces
    # GPN is assumed if there is no interface information in landb
    domain = "GPN"
    if !interfaces.nil?
      if interfaces.interface_information.kind_of?(Array)
        # If there are multiple interfaces, the first one is chosen
        domain = interfaces.interface_information.first[:network_domain_name]
      else
        domain = interfaces.interface_information.network_domain_name
      end
    end 

    Facter.add("landb_network_domain") do
      setcode do
        "#{domain}"
      end
    end

    "#{domain}"
  end

end
 
def get_landb_information
  if File.exists?("/etc/puppet/landb_config.yaml")
    facter_landb = LandbWrapper.new
    landb_info   = {}
    if !facter_landb.nil? # Could be nil if yaml file is not possible to parse
      landb_info[:landb_location]          = facter_landb.add_landb_location
      landb_info[:landb_responsible_name]  = facter_landb.add_responsible_name
      landb_info[:landb_responsible_email] = facter_landb.add_responsible_email
      landb_info[:landb_rackname]          = facter_landb.add_rackname
      landb_info[:landb_network_domain]    = facter_landb.add_network_domain
    end
  end  

  landb_info 
end

# -------------- Start

facts_cache_dir  = '/etc/puppet/facts.d'
landb_cache_file = facts_cache_dir + '/landb_cache.yaml'

facts_cache_ttl = 432000 #1 week (in seconds)

debug = false 

if File::exist?(landb_cache_file) then
  landb_cache = YAML.load_file(landb_cache_file)
  cache_time  = File.mtime(landb_cache_file)
else   
  puts "Err: failed to load landb.yaml local cache" if debug
  landb_cache = nil
  cache_time  = Time.at(0)
end

# Writes if cache has been purged, or fact exceeds TTL
if !landb_cache || (Time.now - cache_time) > facts_cache_ttl
  begin
    landb_data = get_landb_information
  rescue 
    puts "Couldn't contact landb" if debug
    exit
  end
  begin
    Dir.mkdir(facts_cache_dir) if !File::exists?(facts_cache_dir)
    File.open(landb_cache_file, 'w') do |out|
      YAML.dump(landb_data, out)
    end
  rescue
    puts "Err: failed to write landb.yaml cache file." if debug
  end
else
  landb_cache = YAML.load_file(landb_cache_file)
  landb_cache.each do |key, value|
    Facter.add("#{key}") { setcode { "#{value}" } }
  end
end

rescue LoadError 
  puts 'LoadError: gem landb/savon are not installed. Install them using "yum install rubygem-landb rubygem-savon"'
end  
