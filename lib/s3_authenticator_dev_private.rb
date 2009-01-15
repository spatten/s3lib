module S3Lib
  require 'time'
  
  def self.request(verb, request_path, headers = {})
    s3requester = AuthenticatedRequest.new()
    s3requester.make_authenticated_request(verb, request_path, headers)
  end  
  
  class AuthenticatedRequest
    
    POSITIONAL_HEADERS = ['content-md5', 'content-type', 'date']      
    
    def make_authenticated_request(verb, request_path, headers = {})
      @verb = verb
      @headers = headers
      fix_date
    end
    
    private
    
    def fix_date
      @headers['date'] ||= Time.now.httpdate
    end
  
    def canonical_string
      "#{@verb.to_s.upcase}\n#{canonicalized_headers}"
    end
    
    def canonicalized_headers
      "#{canonicalized_positional_headers}"
    end
    
    def canonicalized_positional_headers
      POSITIONAL_HEADERS.collect do |header|
        (@headers[header] || "") + "\n"
      end.join
    end    
  
  end
end