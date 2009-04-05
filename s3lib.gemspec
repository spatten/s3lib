# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{s3lib}
  s.version = "0.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Scott Patten"]
  s.date = %q{2009-04-05}
  s.description = %q{This library forms the basis for building a library to talk to Amazon S3 using Ruby.  It is used as an example of how to build an Amazon S3 interface in The S3 Cookbook (http://thes3cookbook.sopobo.com)}
  s.email = %q{scott@thes3cookbook.com}
  s.executables = ["s3lib", "s3sh_as"]
  s.files = [
    "Rakefile",
    "bin/s3lib",
    "bin/s3sh_as",
    "lib/acl.rb",
    "lib/acl_access.rb",
    "lib/acl_creating_a_grant_recipe.rb",
    "lib/acl_reading_acl_recipe.rb",
    "lib/acl_refreshing_cached_grants_recipe.rb",
    "lib/bucket.rb",
    "lib/bucket_before_refactoring.rb",
    "lib/bucket_create.rb",
    "lib/bucket_find.rb",
    "lib/bucket_with_acl_mixin.rb",
    "lib/error_handling.rb",
    "lib/grant.rb",
    "lib/grant_creating_a_grant_recipe.rb",
    "lib/grant_reading_acl_recipe.rb",
    "lib/object.rb",
    "lib/object_from_bucket_test.rb",
    "lib/object_take1.rb",
    "lib/object_with_acl_mixin.rb",
    "lib/put_with_curl_test.rb",
    "lib/s3_authenticator.rb",
    "lib/s3_authenticator_dev.rb",
    "lib/s3_authenticator_dev_private.rb",
    "lib/s3_errors.rb",
    "lib/s3lib.rb",
    "lib/s3lib_with_mixin.rb",
    "lib/service.rb",
    "lib/service_dev.rb",
    "test/acl_test.rb",
    "test/amazon_headers_test.rb",
    "test/canonical_resource_test.rb",
    "test/canonical_string_tests.rb",
    "test/first_test.rb",
    "test/first_test_private.rb",
    "test/full_test.rb",
    "test/s3_authenticator_test.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://thes3cookbook.sopobo.com}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{An Amazon S3 interface library used as an example in The S3 Cookbook (http://thes3cookbook.sopobo.com)}
  s.test_files = [
    "test/acl_test.rb",
    "test/amazon_headers_test.rb",
    "test/canonical_resource_test.rb",
    "test/canonical_string_tests.rb",
    "test/first_test.rb",
    "test/first_test_private.rb",
    "test/full_test.rb",
    "test/s3_authenticator_test.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
