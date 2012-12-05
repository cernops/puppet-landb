require 'spec_helper'

describe 'landb::client' do 

  it { should contain_package('rubygem-savon') }
  it { should contain_package('rubygem-landb') }

  it 'generates a file landb_config.yaml from a template' do
    wsdl_string = /wsdl: https:\/\/network.cern.ch\/sc\/soap\/soap/
    should contain_file('/etc/puppet/landb_config.yaml').with({
      'ensure'  => 'file',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0644',
      'replace' => 'true'
    })
     
    should contain_file('/etc/puppet/landb_config.yaml').with_content(wsdl_string)
    # Just a friendly reminder you should test the manifest will do stuff correctly,
    # not its effects
    # File.exists?('/etc/puppet/landb_config.yaml').should be_true
  end
end

describe 'landb_facts' do
  it 'creates a new fact landb_location' do
    Facter.fact(:landb_location).class.should == Facter::Util::Fact
  end
  
  it 'creates a new fact responsible name' do
    Facter.fact(:landb_responsible_name).class.should == Facter::Util::Fact
    Facter.value(:landb_responsible_name).class.should == String
  end

  it 'creates a new fact responsible email' do
    Facter.fact(:landb_responsible_email).class.should == Facter::Util::Fact
    Facter.value(:landb_responsible_email).class.should == String
    # Not looking here to validate an email, just checking if the fact is right
    email_regex = /.*@.*\..*/
    Facter.value(:landb_responsible_email).should match(email_regex)
  end
end if File.exists?("/etc/puppet/landb_config.yaml")
