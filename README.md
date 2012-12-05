h1. Puppet-Landb

h3. A puppet module that handles landb operations using landb-gem and 
    a SOAP connection to network.cern.ch

Test by running "rake spec" on the main directory. Tests will check the manifests
would do the right thing and facter facts are set properly. 

h2. Usage

<pre>
$ facter -p landb_location
</pre> - gets the location of your host 

Other facts: landb_responsible_name, landb_responsible_email... feel free to
extend it.
