module S3Lib
  
  
  class S3ResponseError < StandardError
    attr_reader :response, :amazon_error_type, :status, :s3requester, :io
    def initialize(message, io, s3requester)
      @io = io
      # Get the response and status from the IO object
      @io.rewind
      @response = @io.read
      @io.rewind 
      @status = io.status
      
      # The Amazon Error type will always look like <Code>AmazonErrorType</Code>.  Find it with a RegExp.
      @response =~ /<Code>(.*)<\/Code>/
      @amazon_error_type = $1
      
      # Make the AuthenticatedRequest instance available as well
      @s3requester = s3requester
      
      # Call the standard Error initializer
      # if you put '%s' in the message it will be replaced by the amazon_error_type
      message += "\namazon error type: %s" unless message =~ /\%s/
      super(message % @amazon_error_type)
    end
  end  
  
  # Bucket errors
  
  class NotYourBucketError < S3Lib::S3ResponseError
  end
  
  class BucketNotFoundError < S3Lib::S3ResponseError
  end
  
  class BucketNotEmptyError < S3Lib::S3ResponseError
  end
  
  # Object errors
  
  class ObjectDoesNotExist < StandardError
  end
  
  class ObjectAccessForbidden < StandardError
  end  
  
  class NoContentError < S3Lib::S3ResponseError
  end 
  
  # ACL errors
  class MalformedACLError < S3Lib::S3ResponseError
  end
  
  # Grant errors
  class BadGrantTypeError < StandardError
  end
  
end