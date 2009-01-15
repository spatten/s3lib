#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__),'s3_authenticator')

begin
  req = S3Lib.request(:put, "spatten_sample_bucket/sample_object", :body => "Wheee")
rescue S3Lib::S3ResponseError => e
  puts "Amazon Error Type: #{e.amazon_error_type}"
  puts "HTTP Status: #{e.status.join(',')}"
  puts "Response from Amazon: #{e.response}"
  puts "canonical string: #{e.s3requester.canonical_string}" if e.amazon_error_type == 'SignatureDoesNotMatch'
end