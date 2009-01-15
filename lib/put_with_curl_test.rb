#!/usr/bin/env ruby
require 's3_lib'

module S3Lib
  
  class AuthenticatedRequest
    
    def public_authorization_string
      authorization_string
    end
    
  end
  
end

value = 'testing'
key = 'test.txt'
auth_string = nil
date = Time.now.httpdate
begin
  S3Lib.request(:put, "spatten_test_bucket/#{key}", :body => value, 'date' => date)
rescue => e
  puts e.response
  puts "authorization string:"
  puts e.s3requester.public_authorization_string
  auth_string = e.s3requester.public_authorization_string
end
  
puts "date: #{date}"
puts "Auth String:"
puts auth_string

puts "doing curl"
puts `curl -X PUT -d body=#{value} -d 'Authorization=#{auth_string}' -d 'date=#{date}' http://s3.amazonaws.com/spatten_test_bucket/#{key}` 
puts "end of curl"

obj = S3Lib::S3Object.find('spatten_test_bucket', key)
puts "Content type: #{obj.content_type}"

