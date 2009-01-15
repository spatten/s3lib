# bucket.rb
require File.join(File.dirname(__FILE__), 's3_authenticator')
require 'rexml/document'

module S3Lib
  
  class NotYourBucketError < S3Lib::S3ResponseError
  end
  
  class BucketNotFoundError < S3Lib::S3ResponseError
  end
  
  class BucketNotEmptyError < S3Lib::S3ResponseError
  end  
  
  class Bucket
    
    attr_reader :name, :xml, :prefix, :marker, :max_keys
    
    def self.create(name, params = {})
      params['x-amz-acl'] = params.delete(:access) if params[:access] # translate from :access to 'x-amz-acl'
      begin
        response = S3Lib.request(:put, name, params)
      rescue OpenURI::HTTPError => error
        if error.amazon_error_type == "BucketAlreadyExists"
          S3Lib::NotYourBucketError.new("The bucket '#{name}' is already owned by somebody else", error.io, error.s3requester)
        else
          raise # re-raise the exception if it's not a BucketAlreadyExists error
        end
      end    
      response.status[0] == "200" ? true : false
    end
    
    # passing :force => true will cause the bucket to be deleted even if it is not empty.
    def self.delete(name, params = {})
      if params.delete(:force)
        self.delete_all(name, params)
      end
      begin
        response = S3Lib.request(:delete, name, params)  
      rescue S3Lib::S3ResponseError => error
        case error.amazon_error_type
        when "NoSuchBucket": raise S3Lib::BucketNotFoundError.new("The bucket '#{name}' does not exist.", error.io, error.s3requester)
        when "NotSignedUp": raise S3Lib::NotYourBucketError.new("The bucket '#{name}' is not owned by you.", error.io, error.s3requester)
        when "BucketNotEmpty": raise S3Lib::BucketNotEmptyError.new("The bucket '#{name}' is not empty, so you can't delete it.\nTry using Bucket.delete_all('#{name}') first, or Bucket.delete('#{name}', :force => true).", error.io, error.s3requester)
        else # Re-raise the error if it's not one of the above
          raise
        end
      end            
    end
    
    def delete(params = {})
      self.class.delete(@name, @params.merge(params))
    end
    
    def self.delete_all(name, params = {})
      bucket = Bucket.find(name, params)
      bucket.delete_all
    end
    
    def delete_all
      objects.each do |object|
        object.delete
      end
    end
    
    # Errors for find
    # Trying to find a bucket that doesn't exist will raise a NoSuchBucket error
    # Trying to find a bucket that you don't have access to will raise a NotSignedUp error
    def self.find(name, params = {})
     begin
        response = S3Lib.request(:get, name)
      rescue S3Lib::S3ResponseError => error
        case error.amazon_error_type
        when "NoSuchBucket": raise S3Lib::BucketNotFoundError.new("The bucket '#{name}' does not exist.", error.io, error.s3requester)
        when "NotSignedUp": raise S3Lib::NotYourBucketError.new("The bucket '#{name}' is not owned by you", error.io, error.s3requester)
        else # Re-raise the error if it's not one of the above
          raise
        end
      end
      doc = REXML::Document.new(response)
      Bucket.new(doc, params)
    end
    
    def initialize(doc, params = {})
      @xml = doc.root
      @params = params
      @name = @xml.elements['Name'].text
      @max_keys = @xml.elements['MaxKeys'].text.to_i
      @prefix = @xml.elements['Prefix'].text
      @marker = @xml.elements['Marker'].text
    end
    
    def is_truncated?
      @xml.elements['IsTruncated'].text == 'true'
    end
    
    def objects(params = {})
      refresh if params[:refresh]
      @objects || get_objects
    end
        
    def refresh
      refreshed_bucket = Bucket.find(@name, @params)
      @xml = refreshed_bucket.xml
      @objects = nil
    end
    
    private
    
    def get_objects
      @objects = REXML::XPath.match(@xml, '//Contents').collect do |object|
        key = object.elements['Key'].text
        S3Lib::S3Object.new(self, key, :lazy_load => true)
      end
    end
    
  end
  
end