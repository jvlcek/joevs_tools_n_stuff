#!/usr/bin/env ruby

require 'bundler/setup'
require 'rubygems'
require 'trollop'
require 'yaml'

# TODO: Retrieve these from a YAML config file
BRANCH_NAME      = "cfme-ruby200-5.4-rhel-6"
BRANCH_REF       = "refs/heads/#{BRANCH_NAME}"
REPO_HOME_URL    = "http://pkgs.devel.redhat.com/cgit/rpms"
LOCAL_DISTGIT    = "#{Dir.home}/distgit"
CANDIDATE        = "cfme-5.4-rhel-6-candidate"

module RebuildGemRpms
  PARAMS      = [:gem_list, :file_gem_list]
  BUILD_TYPES = [:mock, :scratch, :brew]

  RebuildGemRpmsBatchResult = Struct.new(:passed, :failed)

  class RebuildGems
    attr_accessor :gem_list, :failed_list, :passed_list, :mock, :scratch, :brew

    def initialize(params)
      raise ArgumentError, "Must supply only one of #{PARAMS}" unless (params.keys & PARAMS).size == 1

      @gem_list = []
      @gem_list = Array.new(params[:gem_list].split(' ')) unless params[:gem_list].nil?
      @gem_list = read_gem_list_from_file(params[:file_gem_list]) unless params[:file_gem_list].nil?
    end

    def mock
      failed_list = []
      passed_list = []

      system('kinit') unless system('klist -s')
      Dir.chdir(LOCAL_DISTGIT) do
        gem_list.each do |gem|
          begin
            system("rhpkg clone #{gem}") unless File.directory?(gem)
            Dir.chdir(gem) do
              system("git checkout cfme-ruby200-5.4-rhel-6")
              result = system("source /opt/rh/ruby200/enable; rhpkg srpm; mock -r #{CANDIDATE} #{gem}*.el6.src.rpm")
              if result
                passed_list << gem
              else
                failed_list << gem
                system("cp /var/lib/mock/cfme-5.4-rhel-6-candidate/result/*.log .")
              end
            end
          rescue => e
            puts "Continuing from exception\n#{e.message}\n#{e.backtrace.inspect}"
          end
        end
      end
      gem_list = passed_list

      RebuildGemRpmsBatchResult.new(gem_list, failed_list)
    end

    def scratch
      failed_list = []
      passed_list = []

      system('kinit') unless system('klist -s')
      Dir.chdir(LOCAL_DISTGIT) do
        gem_list.each do |gem|
          begin
            system("rhpkg clone #{gem}") unless File.directory?(gem)
            Dir.chdir(gem) do
              system("git checkout cfme-ruby200-5.4-rhel-6")
              result = system("source /opt/rh/ruby200/enable; rhpkg srpm; rhpkg scratch-build --srpm --nowait")
              if result
                passed_list << gem
              else
                failed_list << gem
              end
            end
          rescue => e
            puts "Continuing from exception\n#{e.message}\n#{e.backtrace.inspect}"
          end
        end
      end
      gem_list = passed_list

      RebuildGemRpmsBatchResult.new(gem_list, failed_list)
    end

    def brew
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

    BUILD_TYPES.each do |build_type|
      action = build_type == "mock" ? "passed" : "queued"
      if opts[build_type]
        result = gem_rebuild.send(build_type)
        $stderr.puts "#{build_type} failed for gems: #{result.failed}" if result.failed.any?
        puts "#{build_type} #{action} for: #{result.passed}" if result.passed.any?
      end
    end

  end
end
