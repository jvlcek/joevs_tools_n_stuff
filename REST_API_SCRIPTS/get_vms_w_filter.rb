#!/usr/bin/env ruby

require 'rest-client'
require 'json'

class MiqApiSimpleExample
  attr_accessor :miq_ipaddr

  def initialize(ipaddr)
    @miq_ipaddr = ipaddr
  end

  def get_vms
    miq_url       = "https://#{miq_ipaddr}"
    miq_user      = "admin"
    miq_password  = "smartvm"

    begin
      RestClient.log = 'stdout'

      response = RestClient::Request.new(:method     => "get",
                                         :url        => miq_url + "/api/vms/?expand=resources&attributes=name,vendor&filter[]=name=\"JoeV*\"",
                                         :headers    => {:content_type => "application/json"},
                                         :user       => miq_user,
                                         :password   => miq_password,
                                         :params     => { :expand => "resources", :attributes => "name" },
                                         :verify_ssl => false).execute
      puts "Reply: "
      puts JSON.pretty_generate(JSON.parse(response.body.strip))

      puts "\nResources: "
      puts JSON.pretty_generate(JSON.parse(response.body.strip)["resources"])

    rescue Exception => e
      puts "Error: #{e.message}"
      puts "Response: #{e.response}"
    end
  end

  def error_exit(msg)
    puts msg
    exit
  end
end

if __FILE__ == $PROGRAM_NAME
    error_exit "No MiQ Appliance hostname or ipaddr specified" unless ARGV.count == 1

  MiqApiSimpleExample.new(ARGV[0]).get_vms
end
  


