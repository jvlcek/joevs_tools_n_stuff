#!/usr/bin/env ruby

require "json"
require "pp"
require "optimist"

# class ApiOidcExerciser

class OidcApiExcersiser

  attr_reader :user, :password, :infra_man_server, :oidc_client_secret, :oidc_server, :oidc_realm, :oidc_client_id, :token_endpoint, :token_introspection_endpoint
  attr_accessor :opts

  def initialize
    parse(ARGV)

    @user = @opts[:user]
    @password = @opts[:password]

    conf_hash = conf_to_hash(@opts[:conf_file])


    @infra_man_server = conf_hash["ServerName"]
    @infra_man_server.gsub!(/https:\/\//, '')
    @infra_man_server.gsub!(/\//, '')

    @oidc_client_secret = conf_hash["OIDCOAuthClientSecret"]

    # JJV REMOVE THESE
    @oidc_server = "joev-keycloak.jvlcek.redhat.com:8443"
    @oidc_realm = "auth/realms/miq"


    @oidc_client_id = conf_hash["OIDCCLientID"]
    @token_introspection_endpoint = conf_hash["OIDCOAuthIntrospectionEndpoint"]
    @token_endpoint = @token_introspection_endpoint.gsub(/introspect/, '')
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
      if l.empty?
        ["empty", nil]
      else
        Array(l.split(' ').take(2))
      end
    end ]
  end

  def parse(args)
    @opts = Optimist.options(args) do
        banner "Usage: ruby #{$PROGRAM_NAME} [opts]\n"

        opt :user,
            "An OIDC user",
            :short       => "u",
            :type       => :string,
            :required   => true

        opt :password,
            "OIDC user's password",
            :short       => "p",
            :type       => :string,
            :required   => true

        opt :conf_file,
            "OIDC config file, manageiq-external-auth-openidc.conf",
            :short       => "c",
            :type       => :string,
            :required   => true
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
