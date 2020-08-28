#!/usr/bin/env ruby

require "json"
require "pp"
require "optimist"

# require 'pry'; binding.pry # JJV

class OidcApiExcersiserError < StandardError; end

class OidcApiExcersiser

  attr_reader :user, :password, :infra_man_server,
              :oidc_client_secret, :oidc_client_id,
              :token_endpoint, :token_introspection_endpoint
  attr_accessor :opts, :conf_hash

  def initialize
    parse(ARGV)

    @user = @opts[:user]
    @password = @opts[:password]

    @conf_hash = get_conf_hash
    @infra_man_server = server_name
    @oidc_client_secret = client_secret
    @oidc_client_id = client_id
    @token_introspection_endpoint = introspection_endpoint

    @token_endpoint = token_endpoint
  end

  def get_conf_hash

    return {} if @opts[:conf_file].nil?

    conf_to_hash(@opts[:conf_file])
  end

  def server_name
    return @opts[:servername] unless @opts[:servername].nil?

    raise OidcApiExcersiserError, "No ServerName found" unless @conf_hash.key?("servername")

    server_name = @conf_hash["servername"]
    server_name.gsub!(/https:\/\//, '')
    server_name.gsub!(/\//, '')

    server_name
  end

  def client_secret
    return @opts[:oidcclientsecret] unless @opts[:oidcclientsecret].nil?

    raise OidcApiExcersiserError, "No OIDCClientSecret found" unless @conf_hash.key?("oidcclientsecret")

    @conf_hash["oidcclientsecret"]
  end

  def client_id
    return @opts[:oidcclientid] unless @opts[:oidcclientid].nil?

    raise OidcApiExcersiserError, "No OIDCClientId found" unless @conf_hash.key?("oidcclientid")

    @conf_hash["oidcclientid"]
  end

  def introspection_endpoint
    return @opts[:oidcoauthintrospectionendpoint] unless @opts[:oidcoauthintrospectionendpoint].nil?

    raise OidcApiExcersiserError, "No IntrospectionEndpoint found" unless @conf_hash.key?("oidcoauthintrospectionendpoint")

    @conf_hash["oidcoauthintrospectionendpoint"]
  end

  def token_endpoint
    return @opts[:oidcprovidertokenendpoint] unless @opts[:oidcprovidertokenendpoint].nil?
    return @conf_hash["oidcprovidertokenendpoint"] if @conf_hash.key?("oidcprovidertokenendpoint")

    @token_introspection_endpoint.gsub(/introspect/, '')
  end


  def display_setup
    puts "   ----------------------------- ----------------------------------------"
    puts "@oidc_client_id               ->#{@oidc_client_id}<-"
    puts "@token_endpoint               ->#{@token_endpoint}<-"
    puts "@token_introspection_endpoint ->#{@token_introspection_endpoint}<-"
    puts "@infra_man_server             ->#{@infra_man_server}<-"
    puts "@oidc_client_secret           ->#{@oidc_client_secret}<-"
  end
  
  def api_basic_admin
  
    puts_banner("Enter any key when ready to accessing MiQ API Using basic admin:password?")
    _ready_continue = gets
  
    cmd = "curl -L -vvv -k --user admin:smartvm -X GET -H 'Accept: application/json' https://#{@infra_man_server}/api/users"
    res = JSON.parse(run_command(cmd))
    puts_green(JSON.pretty_generate(res))
  end
  
  def api_jwt
    puts_banner("Enter any key when ready access MiQ API with a JWT Token?")
    _ready_continue = gets
  
    puts_banner("Request the JWT Token and Refresh Token")
    cmd = "curl -k -L --user #{@user}:#{@password} -X POST -H \"Content-Type: application/x-www-form-urlencoded\" " +
          "-d \"grant_type=password\" -d \"client_id=#{@oidc_client_id}\" -d \"client_secret=#{@oidc_client_secret}\" " +
          "-d \"username=#{@user}\" -d \"password=#{@password}\" #{@token_endpoint}"
    res = JSON.parse(run_command(cmd))
    puts_green(JSON.pretty_generate(res))
  
    access_token = res["access_token"]
    puts "\n access_token:"
    puts_green(access_token)
  
    puts_banner("Use the access_token to do Token Introspection")
    cmd = "curl -k -L --user #{@oidc_client_id}:#{@oidc_client_secret} -X POST " +
          "-H \"Content-Type: application/x-www-form-urlencoded\" " +
          "-d \"token=#{access_token}\" #{@token_introspection_endpoint}"
    res = JSON.parse(run_command(cmd))
  
    puts "\n Token Introspection Response:"
    puts_green(JSON.pretty_generate(res))
  
    puts_banner("Accessing MiQ API using the JWT:")
    cmd = "curl -L -vvv -k -X GET -H \"Authorization: Bearer #{access_token}\" https://#{@infra_man_server}/api/users"
    res = JSON.parse(run_command(cmd))
  
    puts "API Response:"
    puts_green(JSON.pretty_generate(res))
  end
  
  
  def api_auth_token
    puts_banner("Enter any key when ready to use the MiQ API Auth Token?")
    _ready_continue = gets
  
    cmd = "curl -k -L --user #{@user}:#{@password} -X POST " +
          "-H \"Content-Type: application/x-www-form-urlencoded\" " +
          "-d \"grant_type=password\" " +
          "-d \"client_id=#{@oidc_client_id}\" " +
          "-d \"client_secret=#{@oidc_client_secret}\" " +
          "-d \"username=#{@user}\" " +
          "-d \"password=#{@password}\" " +
          "#{@token_endpoint}"
    res = JSON.parse(run_command(cmd))
    puts_green(JSON.pretty_generate(res))
  
    access_token = res["access_token"]
    puts "\n access_token:"
    puts_green(access_token)
  
    puts_banner("Use the access_token to do Token Introspection")
    cmd = "curl -k -L --user #{@oidc_client_id}:#{@oidc_client_secret} -X POST " +
          "-H \"Content-Type: application/x-www-form-urlencoded\" " +
          "-d \"token=#{access_token}\" " +
          "#{@token_introspection_endpoint}"
    res = JSON.parse(run_command(cmd))
  
    puts "\n Token Introspection Response:"
    puts_green(JSON.pretty_generate(res))
  
    puts_banner("Request an MiQ API Authentication Token:")
  
    cmd = "curl -L -vvv -k -X GET -H \"Authorization: Bearer #{access_token}\" https://#{@infra_man_server}/api/auth"
    res = JSON.parse(run_command(cmd))
    puts_green(JSON.pretty_generate(res))
  
    auth_token = res["auth_token"]
    puts "\n auth_token:"
    puts_green(auth_token)
  
    puts_banner("Accessing MiQ API Using the MiQ API Auth Token:")
  
    cmd = "curl -L -vvv -k -X GET  -H \"Accept: application/json\" -H \"X-Auth-Token: #{auth_token}\" https://#{@infra_man_server}/api/users"
    res = JSON.parse(run_command(cmd))
  
    puts "API Response:"
    puts_green(JSON.pretty_generate(res))
  end
  
  def puts_red(str)
    puts "\e[31m"
    puts str
    puts "\e[0m"   # clear format
  end
  
  def puts_green(str)
    puts "\e[32m"
    puts str
    puts "\e[0m"   # clear format
  end
  
  def puts_banner(str)
    puts "\e[36m"
    puts "\n   ----------------------------------------------------------------------"
    puts "   *** #{str}"
    puts "   ----------------------------------------------------------------------"
    puts "\e[0m"   # clear format
  end
  
  def run_command(cmd)
    puts_red "Running Command: \n #{cmd}"
    %x[#{cmd}]
  end

  def conf_to_hash(fn)
    Hash[File.readlines(fn, chomp: true).map do |l|
      if l.strip.empty?
        ["empty", nil]
      else
        Array(l.split(' ').take(2))
      end
    end ].transform_keys(&:downcase)
  end

  def parse(args)
    @opts = Optimist.options(args) do
        banner "Usage: ruby #{$PROGRAM_NAME} [opts]\n"

        opt :user,
            "The user being authenticated",
            :short       => "u",
            :type       => :string,
            :required   => true

        opt :password,
            "The password for the user being authenticated",
            :short       => "p",
            :type       => :string,
            :required   => true

        opt :conf_file,
            "OIDC config file, manageiq-external-auth-openidc.conf",
            :short       => "c",
            :type       => :string,
            :required   => false

        opt :servername,
            "The ManageIQ server name. ServerName from the config file without the https:// e.g. my-miq.example.com",
            :short       => "n",
            :type       => :string,
            :required   => false

        opt :oidcclientsecret,
            "OIDCClientSecret from the OpenID-Connect configuration.",
            :short       => "s",
            :type       => :string,
            :required   => false

        opt :oidcclientid,
            "OIDCClientID from the OpenID-Connect configuration.",
            :short       => "d",
            :type       => :string,
            :required   => false

        opt :oidcoauthintrospectionendpoint,
            "OIDCOauthIntrospectionEndpoint from the OpenID-Connect configuration.",
            :short       => "i",
            :type       => :string,
            :required   => false

        opt :oidcprovidertokenendpoint,
            "OIDCProviderTokenEndpoint from the OpenID-Connect configuration. Or OIDCOauthIntrospectionEndpoint without /introspection",
            :short       => "t",
            :type       => :string,
            :required   => false
       end
       puts_red("User provided settings: #{@opts}")
  end
  @opts
end


  
if __FILE__ == $PROGRAM_NAME   
  oidc_api_exerciser = OidcApiExcersiser.new

  oidc_api_exerciser.display_setup
  oidc_api_exerciser.api_basic_admin
  oidc_api_exerciser.api_jwt
  oidc_api_exerciser.api_auth_token
end
