require 'rubygems'
require 'rake/testtask'

task :default => :test

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/*_test.rb']
  # t.verbose = true
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "s3lib"
    gemspec.summary = "An Amazon S3 interface library used as an example in The S3 Cookbook (http://thes3cookbook.com)"
    gemspec.email = 'scott@scottpatten.ca'
    gemspec.homepage = 'http://thes3cookbook.com'
    gemspec.description = "This library forms the basis for building a library to talk to Amazon S3 using Ruby.  It is used as an example of how to build an Amazon S3 interface in The S3 Cookbook (http://thes3cookbook.com)"
    gemspec.authors = ["Scott Patten"]
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end
