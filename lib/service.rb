# service.rb
require File.join(File.dirname(__FILE__), 's3_authenticator')
require 'rexml/document'

module S3Lib
  
  class Service
    
    def self.buckets
      response = S3Lib.request(:get, '')
      doc = REXML::Document.new(response)
      xml = doc.root
      REXML::XPath.match(xml, '//Buckets/Bucket').collect do |bucket_xml|
        Bucket.new(bucket_xml)
      end
    end
        
  end
  
end

if __FILE__ == $0
  S3Lib::Service.buckets
end