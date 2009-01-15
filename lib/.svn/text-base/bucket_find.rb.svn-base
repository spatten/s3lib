# s3_bucket.rb
require File.join(File.dirname(__FILE__), '..', 's3_authenticator')
require 'rexml/document'

module S3Lib
  
  class Bucket
    
    attr_reader :xml, :prefix, :marker, :max_keys
    
    def self.find(name, params = {})
      response = S3Lib.request(:get, name)
      doc = REXML::Document.new(response)
      Bucket.new(doc)
    end
    
    def initialize(doc)
      @xml = doc.root
      @name = @xml.elements['Name'].text
      @max_keys = @xml.elements['MaxKeys'].text.to_i
      @prefix = @xml.elements['Prefix'].text
      @marker = @xml.elements['Marker'].text
    end
    
    def is_truncated?
      @xml.elements['IsTruncated'].text == 'true'
    end
    
    def objects
      REXML::XPath.match(@xml, '//Contents').collect do |object|
        S3Lib::S3Object.new(object)
      end
    end
    
  end
  
end

if __FILE__ == $0
  S3Lib::Bucket.find('spatten_syncdemo')
end