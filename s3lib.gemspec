# s3-lib.gemspec
require 'rubygems'
spec = Gem::Specification.new do |spec|
  spec.name = 's3lib'
  spec.summary = "An Amazon S3 interface library used as an example in The S3 Cookbook (http://thes3cookbook.com)"
  spec.description = "This library forms the basis for building a library to talk to Amazon S3 using Ruby.  It is used as an example of how to build an Amazon S3 interface in The S3 Cookbook (http://thes3cookbook.com)"
  spec.author = 'Scott Patten'
  spec.email = 'scott@thes3cookbook.com'
  spec.homepage = 'http://thes3cookbook.com'
  
  spec.executables = ['bin/s3sh_as', 'bin/s3lib']
  spec.executables << 's3sh_as'
  spec.executables << 's3lib'
  spec.test_files = %w(test/acl_test.rb test/first_test_private.rb test/test_amazon_headers.rb test/canonical_string_tests.rb
                       test/full_test.rb test/test_canonical_resource.rb test/first_test.rb test/s3_authenticator_test.rb)
  spec.files = %w(lib/acl.rb lib/acl_access.rb lib/error_handling.rb lib/s3_authenticator.rb 
                  lib/grant.rb lib/s3_errors.rb lib/bucket.rb lib/object.rb lib/s3lib.rb lib/service.rb) + 
               ['bin/s3sh_as', 'bin/s3lib'] + spec.test_files
  spec.has_rdoc = false
  
  spec.add_dependency('rest-open-uri')
  
  spec.version = '0.1.16'
end