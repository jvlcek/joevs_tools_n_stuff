#!/usr/bin/env ruby

require 'bundler/setup'
require 'rubygems'
require 'trollop'
require 'yaml'

# TODO: Retrieve these from a YAML config file
BRANCH_LIST_FILE = "distgit_have_branch_list_small"
BRANCH_NAME      = "cfme-ruby200-5.4-rhel-6"
BRANCH_REF       = "refs/heads/#{BRANCH_NAME}"
REPO_HOME_URL    = "http://pkgs.devel.redhat.com/cgit/rpms"
LOCAL_DISTGIT    = "#{Dir.home}/distgit"
CANDIDATE        = "cfme-5.4-rhel-6-candidate"

module RebuildGemRpms
  PARAMS      = [:gem_list, :file_gem_list]
  ACTIONS     = [:mock, :scratch, :brew]

  RebuildGemRpmsBatchResult = Struct.new(:passed, :failed)

  class RebuildGems
    attr_accessor :gem_list, :failed_list, :passed_list, :mock, :scratch, :brew

    def initialize(params)
      raise ArgumentError, "Must supply only one of #{PARAMS}" unless (params.keys & PARAMS).size == 1

      @gem_list = []
      @gem_list = Array.new(params[:gem_list].split(' ')) unless params[:gem_list].nil?
      @gem_list = read_gem_list_from_file(params[:file_gem_list]) unless params[:file_gem_list].nil?

      @failed_list = gem_list
      @passed_list = []
    end

    def mock
      puts "Running Mock Build"

      Dir.chdir(LOCAL_DISTGIT) do
        begin
          system("rhpkg clone #{line}") unless File.directory?(line)
          Dir.chdir(line) do
            system("git checkout cfme-ruby200-5.4-rhel-6")
            result = system("source /opt/rh/ruby200/enable; rhpkg srpm; mock -r #{CANDIDATE} #{line}*.el6.src.rpm")
            if result
              failed_list.delete(item)
              passed_list << item
            else
              system("cp /var/lib/mock/cfme-5.4-rhel-6-candidate/result/*.log .")
            end
          end
        rescue => e
          puts "Recoverable exception Encountered"
          puts e.message
          puts e.backtrace.inspect
          puts "Continuing from exception"
        end
      end

      RebuildGemRpmsBatchResult.new(passed_list, failed_list)
    end

    def scratch
      puts "Running scratch Build"
      # TODO: implement this
      RebuildGemRpmsBatchResult.new(passed_list, failed_list)
    end

    def brew
      puts "Running brew Build"
      # TODO: implement this
      RebuildGemRpmsBatchResult.new(passed_list, failed_list)
    end

    private

    def read_gem_list_from_file(path)
      list = []
      File.open("#{path}", "r") do |f|
        f.each_line do |line|
          line.strip!
          list << line
        end
      end
      list
    end
  end

  def self.read_options
    opts = Trollop.options do
      banner "Rebuild the specified gems."
      opt :mock,          "Attempt mock build"
      opt :scratch,       "Attempt scratch build"
      opt :brew,          "Attempt brew build"
      opt :gem_list,      "A space saparated list of gems to build", :type => :string
      opt :file_gem_list, "A file containing a list gems to build, one per line", :type => :string
    end

    opts
  end

  # from bash:
  # et_tools arg1 arg2
  if __FILE__ == $PROGRAM_NAME

    opts = read_options

    params = {}
    params[:gem_list]      = opts[:gem_list]      unless opts[:gem_list].nil?
    params[:file_gem_list] = opts[:file_gem_list] unless opts[:file_gem_list].nil?

    gem_rebuild = RebuildGems.new(params)

    ACTIONS.each do |action|
      puts "\naction ->#{action}<-"
      if opts[action]
        result = gem_rebuild.send(action)
        $stderr.puts "#{action} failed for gems: #{result.failed}" if result.failed.any?
        puts "#{action} passed for: #{result.passed}" if result.passed.any?
      end
    end

  end
end
