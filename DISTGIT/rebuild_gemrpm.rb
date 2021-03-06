#!/usr/bin/env ruby

require 'awesome_spawn'
require 'rubygems'
require 'trollop'
require 'yaml'

# TODO: Retrieve these from a YAML config file
BRANCH_NAME      = "cfme-ruby200-5.4-rhel-6"
BRANCH_REF       = "refs/heads/#{BRANCH_NAME}"
REPO_HOME_URL    = "http://pkgs.devel.redhat.com/cgit/rpms"
LOCAL_DISTGIT    = "#{Dir.home}/distgit"
CANDIDATE        = "cfme-5.4-rhel-6-candidate"
COMMIT_MESSAGE   = "Remove the rubyabi macro"

# actio pugna
REMOTE_BREW_CMD       = "~/bin/brew"
TASKINFO_CMD          = "#{REMOTE_BREW_CMD} taskinfo"

module RebuildGemRpms
  PARAMS      = [:gem_list, :file_gem_list]
  BUILD_TYPES = [:mock, :scratch, :brew]

  class RebuildGemResultItem
    attr_accessor :name, :task_id, :brew_url

    def initialize(name, task_id = nil, brew_url = nil)
      @name     = name
      @task_id  = task_id
      @brew_url = brew_url
    end

    def to_s
      format("%-30s %-10s %s", name, task_id, brew_url)
    end
  end

  class RebuildGemsBatchResult
    attr_accessor :passed, :failed

    def initialize(passed, failed)
      @passed = passed
      @failed = failed
    end

    def to_s
      if failed.any?
        puts "\n\tfailed:"
        puts failed.collect(&:to_s)
      end
      if passed.any?
        puts "\n\tqueued:"
        puts passed.collect(&:to_s)
      end
    end

    def brew_jobs_succeeeded?
      puts "\n\t Brew Jobs Succeeded"
      passed.each do |gem|
        puts "#{gem} #{build_succeeded?(gem.task_id)}"
      end if passed.any?
    end

    def build_state(taskid)
      as_ret = AwesomeSpawn.run("#{TASKINFO_CMD} #{taskid} | grep ^State:")
      raise "Error: Accessing Build #{taskid} - #{as_ret.output}\n#{as_ret.error}" unless as_ret.exit_status == 0
      as_ret.output.split(" ")[1]
    end

    def build_succeeded?(task_id)
      return true if task_id.nil?

      current_state = build_state(task_id)
      STDOUT.write "\r - "
      while current_state == "open" || current_state == "free"
        STDOUT.write "\r . "
        sleep 1
        STDOUT.write "\r - "
        sleep 1
        current_state = build_state(task_id)
      end
      return true if current_state == "closed"
      false
    end
  end

  class RebuildGems
    attr_accessor :gem_list, :mock, :scratch, :brew, :build_type

    def initialize(params)
      raise ArgumentError, "Must supply only one of #{PARAMS}" unless (params.keys & PARAMS).size == 1
      @build_type = nil
      @gem_list = []
      gems = Array.new(params[:gem_list].split(' ')) unless params[:gem_list].nil?
      gems = read_gem_list_from_file(params[:file_gem_list]) unless params[:file_gem_list].nil?
      gems.each { |gem| @gem_list << RebuildGemResultItem.new(gem) }
    end

    def record_passed(as_ret, gem)
      puts "Passed: - #{as_ret.output}\n#{as_ret.error}"
      gem.task_id  = as_ret.output.split("\n").select{|x| x.match("Created task:")}[0].to_s.split(" ")[2]
      gem.brew_url = as_ret.output.split("\n").select{|x| x.match("Task info:")}[0].to_s.split(" ")[2]
    end

    def record_failure(as_ret)
      puts "Error: - #{as_ret.output}\n#{as_ret.error}"
      AwesomeSpawn.run("cp /var/lib/mock/cfme-5.4-rhel-6-candidate/result/*.log .") if build_type == :mock
    end

    def build_loop
      failed_list = []
      passed_list = []

      system('kinit') unless system('klist -s')
      Dir.chdir(LOCAL_DISTGIT) do
        gem_list.each do |gem|
          begin
            AwesomeSpawn.run("rhpkg clone #{gem.name}") unless File.directory?(gem.name)
            Dir.chdir(gem.name) do
              as_ret = yield(gem.name)
              if as_ret.exit_status == 0
                passed_list << gem
                record_passed(as_ret, gem)
              else
                failed_list << gem
                record_failure(as_ret)
              end
            end
          rescue => e
            failed_list << gem
            puts "\t***Continuing from exception\n#{e.message}\n#{e.backtrace.inspect}"
          end
        end
      end
      gem_list = passed_list

      RebuildGemsBatchResult.new(gem_list, failed_list)
    end

    def mock
      @build_type = :mock
      build_loop do |gem_name|
        AwesomeSpawn.run("git checkout #{BRANCH_NAME}")
        AwesomeSpawn.run("source /opt/rh/ruby200/enable; rhpkg srpm; mock -r #{CANDIDATE} #{gem_name}*.el6.src.rpm")
      end
    end

    def scratch
      @build_type = :scratch
      build_loop do
        AwesomeSpawn.run("git checkout #{BRANCH_NAME}")
        AwesomeSpawn.run("source /opt/rh/ruby200/enable; rhpkg srpm; rhpkg scratch-build --srpm --nowait")
      end
    end

    def brew
      @build_type = :brew
      build_loop do
        AwesomeSpawn.run("git checkout #{BRANCH_NAME}")
        AwesomeSpawn.run("git add *.spec") # assume spec changes, git will ignore none.
        AwesomeSpawn.run("git commit -m \"#{COMMIT_MESSAGE}\"")
        AwesomeSpawn.run("rhpkg push; rhpkg build --nowait")
      end
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
      opt :wait,          "wait for brew job"
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
      if opts[build_type]
        result = gem_rebuild.send(build_type)
        result.to_s
        result.brew_jobs_succeeeded? if opts[:wait]
      end
    end

  end
end
