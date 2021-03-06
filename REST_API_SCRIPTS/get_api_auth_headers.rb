#!/usr/bin/env ruby

require 'json'
require 'net/http'
require 'openssl'
require 'uri'

class MiqApiSimpleExample
  attr_accessor :ipaddr, :user, :pw, :port

  def initialize(ipaddr, user = "admin", pw = "smartvm")
    @ipaddr = ipaddr
    @user = user
    @pw = pw
    @port = 443 # HTTP uses port 80 and HTTPS uses port 443
  end

  def self.error_exit(msg)
    puts msg
    exit
  end

  def get_api
    headers = {'Accept' => 'application/json', 'authorization' =>  'Basic ' + ["#{user}:#{pw}"].pack('m0') }

    begin

      net_http = Net::HTTP.new(ipaddr, port)
      net_http.use_ssl = true
      net_http.read_timeout = 300
      net_http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      res = net_http.get("/api", headers)

      puts "Reply: "
      puts JSON.pretty_generate(JSON.parse(res.body.strip))

    rescue Exception => e
      puts "Error: #{e.message}"
      puts "Response: #{e.response}"
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  MiqApiSimpleExample.error_exit "No MiQ Appliance hostname or ipaddr specified" unless ARGV.count == 1

  MiqApiSimpleExample.new(ARGV[0]).get_api
end
