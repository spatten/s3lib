# s3_bucket.rb
require File.join(File.dirname(__FILE__), 's3_authenticator')
module S3Lib
  
  class NotYourBucketError < S3Lib::S3ResponseError
  end
  
  class Bucket
  
    # Todo:
    # Class methods
    # Bucket::find
    # Bucket::delete (have :force => true)
    # Bucket::delete_all_objects
    # Bucket::objects
    # Bucket::new
    # instance methods
    # Bucket#objects
    # Bucket#delete
    # Bucket#delete_all_objects
    # Bucket#each
  
    def self.create(name, params = {})
      params['x-amz-acl'] = params.delete(:access) if params[:access] # translate from :access to 'x-amz-acl'
      begin
        response = S3Lib.request(:put, name, params)
      rescue S3Lib::S3ResponseError => error
        if error.amazon_error_type == "BucketAlreadyExists"
          raise S3Lib::NotYourBucketError.new("The bucket '#{name}' is already owned by somebody else", error.io, error.s3requester)
        else
          raise # re-raise the exception if it's not a BucketAlreadyExists error
        end
      end    
      response.status[0] == "200" ? true : false
    end
  
  end
  
end