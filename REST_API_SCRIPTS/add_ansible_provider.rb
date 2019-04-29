#!/usr/bin/env ruby

require 'rest-client'
require 'json'

CFME_URL       = "https://203.0.113.0"
CFME_USER      = "admin"
CFME_PASSWORD  = "smartvm"
TOWER_URL      = "tower.redhat.com"
TOWER_USER     = "admin"
TOWER_PASSWORD = "smarttower"

payload = { "type": "ManageIQ::Providers::AnsibleTower::Provider",
        "name": "ansible-tower-test-01",
        "url": TOWER_URL,
        "credentials": {
            "userid": TOWER_USER,
            "password": TOWER_PASSWORD
        }
}
payload =  JSON.generate(payload)

begin
  RestClient.log = 'stdout'

  response = RestClient::Request.new(:method     => "post",
                                     :url        => CFME_URL + "/api/providers?provider_class=provider",
                                     :payload    => payload,
                                     :headers    => {:content_type=>"application/json"},
                                     :user       => CFME_USER,
                                     :password   => CFME_PASSWORD,
                                     :verify_ssl => false).execute
  puts "Reply: #{response}"
rescue Exception => e
  puts "Error: #{e.message}"
  puts "Response: #{e.response}"
end
