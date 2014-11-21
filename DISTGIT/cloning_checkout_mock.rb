#!/usr/bin/env ruby

# Read an input file, calld distgit_branch_list, listing dist-git repository names
# are report if they have the branch specified in BRANCH_NAME

BRANCH_LIST_FILE = "distgit_have_branch_list_small"
BRANCH_NAME      = "cfme-ruby200-5.4-rhel-6"
BRANCH_REF       = "refs/heads/#{BRANCH_NAME}"
REPO_HOME_URL    = "http://pkgs.devel.redhat.com/cgit/rpms"
LOCAL_DISTGIT    = "#{Dir.home}/distgit"

have_branch = []
missing_branch = []

cur_pwd = Dir.pwd

if ! File.directory?(LOCAL_DISTGIT)
  Dir.mkdir(LOCAL_DISTGIT)
end

begin
  File.open("#{BRANCH_LIST_FILE}", "r") do |f|
    f.each_line do |line|
      line.strip!
      puts "\nJJV -010- line ->#{line}<-"
      puts "JJV -011- #{Dir.pwd}"
      Dir.chdir(LOCAL_DISTGIT) do
        begin
          puts "JJV -020- #{Dir.pwd}"
          if ! File.directory?(line)
            system("rhpkg clone #{line}")
          end
          Dir.chdir(line) do
            puts "JJV -030- #{Dir.pwd}"
            system("git checkout cfme-ruby200-5.4-rhel-6")
            system("source /opt/rh/ruby200/enable; rhpkg   srpm; mock -r cfme-5.4-rhel-6-candidate #{line}*.el6.src.rpm") 


          end
        rescue Exception => e
          puts "Recoverable exception Encountered"
          puts e.message  
          puts e.backtrace.inspect   
          puts "Continuing from exception"
        end
      end
    end
  end
rescue Exception => e
  puts "Unrecoverable exception Encountered"
  puts e.message  
  puts e.backtrace.inspect   
ensure
  Dir.chdir(cur_pwd)
end

puts "JJV -040- #{Dir.pwd}"

      
=begin
    output = `git ls-remote #{REPO_HOME_URL}/#{line} #{BRANCH_NAME}`
    if output.empty?
      missing_branch << line
    else
      have_branch << line
    end
  end
end

puts "\nHave Branch #{BRANCH_NAME} for:"
have_branch.sort.each do |repo|
  puts "    #{repo}"
end

puts "\nMissing Branch #{BRANCH_NAME} for:"
missing_branch.sort.each do |repo|
  puts "    #{repo}"
end
=end
