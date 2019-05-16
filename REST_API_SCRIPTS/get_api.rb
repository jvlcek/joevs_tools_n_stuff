#!/usr/bin/env ruby

require 'net/http'
require 'openssl'
require 'json'

class MiqApiSimpleExample
  attr_accessor :miq_ipaddr, :miq_user, :miq_pw

  def initialize(ipaddr, user = "admin", pw = "smartvm")
    @miq_ipaddr = ipaddr
    @miq_user = user
    @miq_pw = pw
  end

  def self.error_exit(msg)
    puts msg
    exit
  end

  def get_api
    headers = {'Accept' => 'application/json', 'authorization' =>  'Basic ' + ["#{miq_user}:#{miq_pw}"].pack('m0') }

    begin

      net_http = Net::HTTP.new(miq_ipaddr, 443)
      net_http.use_ssl = true
      net_http.read_timeout = 300
      net_http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      response = net_http.get("/api", headers)

      puts "Reply: "
      puts JSON.pretty_generate(JSON.parse(response.body.strip))

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
