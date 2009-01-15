#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__), 'object')
require 'rexml/document'
require 'pp'

bucket_request = S3Lib.request(:get, 'spatten_syncdemo')
bucket_doc = REXML::Document.new(bucket_request.read)
first_object = REXML::XPath.match(bucket_doc, "//Contents").first

# puts first_object

puts "from bucket xml:"
pp first_object.to_hash

puts "from get on object:"
object = S3Lib.request(:get, 'spatten_syncdemo/flowers.jpg')
pp object.meta