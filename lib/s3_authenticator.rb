#!/usr/bin/env ruby
require 'rubygems'
require 'rest-open-uri'

require 'base64'
require 'digest/sha1'
require 'openssl'
require 'pp'

class Hash
  
  def downcase_keys
    res = {}
    each do |key, value|
      key = key.downcase if key.respond_to?(:downcase)
      res[key] = value
    end
    res
  end
  
  def join_values(separator = ',')    
    res = {}
    each do |key, value|
      res[key] = value.respond_to?(:join) ? value.join(separator) : value
    end
    res
  end
  
end

module S3Lib
  
  def self.request(verb, request_path, headers = {})
    begin
      s3requester = AuthenticatedRequest.new()
      req = s3requester.make_authenticated_request(verb, request_path, headers)
    rescue OpenURI::HTTPError=> e
      raise S3Lib::S3ResponseError.new(e.message, e.io, s3requester)
    end
  end

  class AuthenticatedRequest
  
    POSITIONAL_HEADERS = ['content-md5', 'content-type', 'date']  
    AMAZON_HEADER_PREFIX = 'x-amz-'
    HOST = 's3.amazonaws.com'  
    BUCKET_LIST_PARAMS = [:max_keys, :prefix, :marker, :delimiter] 
    SUB_RESOURCE_TYPES = ['acl', 'torrent', 'logging']
  
    def make_authenticated_request(verb, request_path, headers = {})
      @verb = verb
      @request_path = request_path.gsub(/^\//,'') # Strip off the leading '/'
    
      @amazon_id = ENV['AMAZON_ACCESS_KEY_ID']
      @amazon_secret = ENV['AMAZON_SECRET_ACCESS_KEY']    
    
      @headers = headers.downcase_keys.join_values    
      get_bucket_list_params          
      get_bucket_name
      fix_date
      
      req = open(uri_with_bucket_list_params, @headers.merge(:method => @verb, 'Authorization' => authorization_string))
    end
    
    def canonical_string
      "#{@verb.to_s.upcase}\n#{canonicalized_headers}#{canonicalized_resource}"
    end  
  
    def get_bucket_name
      @bucket = ""
      return unless @headers.has_key?('host')
      @headers['host'] = @headers['host'].downcase
      return if @headers['host'] == 's3.amazonaws.com'
      if @headers['host'] =~ /^([^.]+)(:\d\d\d\d)?\.#{HOST}$/
        @bucket = $1.gsub(/\/$/,'') + '/'
      else
        @bucket = @headers['host'].gsub(/(:\d\d\d\d)$/, '').gsub(/\/$/,'') + '/'
      end    
    end
  
    def fix_date
      @headers['date'] ||= Time.now.httpdate
      @headers.delete('date') if @headers.has_key?('x-amz-date')    
    end
  
    def uri
      host = @headers['host'] || HOST
      "http://" + File.join(host, URI.escape(@request_path))
    end
        
    def get_bucket_list_params
      @bucket_list_params = {}
      @headers.each do |key, value|
        @bucket_list_params[key] = @headers.delete(key) if BUCKET_LIST_PARAMS.include?(key)
      end
    end
    
    def uri_with_bucket_list_params
      return uri if @bucket_list_params.empty?
      uri_with_params = uri
      bucket_list_string = @bucket_list_params.collect {|key, value| "#{key.to_s.gsub('_', '-')}=#{value}"}.join('&')
      uri_with_params.sub(/\/$/, '') # remove trailing slash
      uri_with_params += '?' unless uri =~ /\?$/ # Add trailing ?
      uri_with_params += bucket_list_string # add bucket list params
      uri_with_params
    end    
  
    def authorization_string
      generator = OpenSSL::Digest::Digest.new('sha1')
      encoded_canonical = Base64.encode64(OpenSSL::HMAC.digest(generator, @amazon_secret, canonical_string)).strip

      "AWS #{@amazon_id}:#{encoded_canonical}"
    end
  
    def canonicalized_headers
      canonicalized_positional_headers + canonicalized_amazon_headers
    end
  
    def canonicalized_positional_headers
      POSITIONAL_HEADERS.collect do |header|
        (@headers[header] || "") + "\n"
      end.join
    end
  
    def canonicalized_amazon_headers
    
      # select all headers that start with x-amz-
      amazon_headers = @headers.select do |header, value|
        header =~ /^x-amz-/
      end
    
      # Sort them alpabetically by key
      amazon_headers = amazon_headers.sort do |a, b|
        a[0] <=> b[0]
      end
    
      # Collect all of the amazon headers like this:
      # {key}:{value}\n
      # The value has to have any whitespace on the left stripped from it 
      # and any new-lines replaced by a single space.
      # Finally, return the headers joined together as a single string and return it.
      amazon_headers.collect do |header, value|
        "#{header}:#{value.lstrip.gsub("\n"," ")}\n"
      end.join
    end
  
    def canonicalized_resource
      canonicalized_resource_string = "/"
      canonicalized_resource_string += @bucket
      canonicalized_resource_string += @request_path  
      canonicalized_resource_string  
    end
    
  end  
end