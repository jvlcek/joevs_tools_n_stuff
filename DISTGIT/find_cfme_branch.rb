#!/usr/bin/env ruby

# Read an input file, calld distgit_branch_list, listing dist-git repository names
# are report if they have the branch specified in BRANCH_NAME 

BRANCH_LIST_FILE = "distgit_branch_list"
BRANCH_NAME      = "refs/heads/cfme-ruby200-5.4-rhel-6"
REPO_HOME_URL    = "http://pkgs.devel.redhat.com/cgit/rpms"

have_branch = []
missing_branch = []

File.open("#{BRANCH_LIST_FILE}", "r") do |f|
  f.each_line do |line|
    line.strip!
    output = `git ls-remote #{REPO_HOME_URL}/#{line} #{BRANCH_NAME}`
    if output.empty?
      missing_branch << line
    else
      have_branch << line
    end
  end
end

puts "\nHave Branch #{BRANCH_NAME} for:"
have_branch.each do |repo|
  puts "    #{repo}"
end

puts "\nMissing Branch #{BRANCH_NAME} for:"
missing_branch.each do |repo|
  puts "    #{repo}"
end

