#!/usr/bin/env ruby

require 'rest-client'
require 'json'

MIQ_URL        = "https://#{ENV['MIQ']}"
TOWER_URL      = ENV['TOWER_URL']
TOWER_USER     = ENV['TOWER_USER']
TOWER_PASSWORD = ENV['TOWER_PASSWORD']

payload = { "type": "ManageIQ::Providers::AnsibleTower::Provider",
            "name": "ansible-tower-test-01",
             "url": TOWER_URL,
             "credentials": { "userid": TOWER_USER, "password": TOWER_PASSWORD }
          }
payload =  JSON.generate(payload)

begin
  RestClient.log = 'stdout'

  response = RestClient::Request.new(:method     => "post",
                                     :url        => MIQ_URL + "/api/providers?provider_class=provider",
                                     :payload    => payload,
                                     :headers    => {:content_type=>"application/json"},
                                     :user       => "admin",
                                     :password   => "smartvm",
                                     :verify_ssl => false).execute
  puts "Reply: #{response}"
rescue Exception => e
  puts "Error: #{e.message}"
  puts "Response: #{e.response}"
end
