#!/usr/bin/env ruby

require 'json'
require 'net/http'
require 'openssl'
require 'uri'

uri = URI.parse("https://#{ENV['MIQ']}/api/users")

http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE

request = Net::HTTP::Post.new(uri.request_uri)
request.basic_auth("admin", "smartvm")
request.body = '
  {
    "name"       : "basicuser4",
    "userid"     : "basicuser4",
    "first_name" : "Basic4",
    "last_name"  : "User4",
    "group"      : { "id" : 4 },
    "password"   : "smartvm"
  }
'
response = http.request(request)
puts JSON.pretty_generate(JSON.parse(response.body.strip))
