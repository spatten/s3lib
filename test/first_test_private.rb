# Make private methods and attributes public so that you can test them
module S3Lib
  class AuthenticatedRequest
  
    attr_reader :headers  
  
    def public_canonicalized_headers
      canonicalized_headers
    end  
  
    def public_canonicalized_positional_headers
      canonicalized_positional_headers
    end
  
    def public_canonical_string
      canonical_string
    end
  
  end  
end

require 'test/unit'
require File.join(File.dirname(__FILE__), '../lib/s3_authenticator')

class S3AuthenticatorTest < Test::Unit::TestCase
  
  def setup
    @s3_test = S3Lib::AuthenticatedRequest.new
  end
  
  def test_http_verb_is_uppercase    
    @s3_test.make_authenticated_request(:get, '/', {'host' => 's3.amazonaws.com'})
    assert_match /^GET\n/, @s3_test.public_canonical_string
  end
  
  def test_canonical_string_contains_positional_headers    
    @s3_test.make_authenticated_request(:get, '', {'content-type' => 'some crazy content type', 
                                                   'date' => 'December 25th, 2007', 
                                                   'content-md5' => 'whee'})
    assert_match /^GET\n#{@s3_test.public_canonicalized_positional_headers}/, @s3_test.public_canonical_string
  end
  
  def test_positional_headers_with_all_headers
    @s3_test.make_authenticated_request(:get, '', {'content-type' => 'some crazy content type', 
                                                   'date' => 'December 25th, 2007', 
                                                   'content-md5' => 'whee'})
    assert_equal "whee\nsome crazy content type\nDecember 25th, 2007\n", @s3_test.public_canonicalized_positional_headers
  end  
  
  def test_positional_headers_with_only_date_header
    @s3_test.make_authenticated_request(:get, '', {'date' => 'December 25th, 2007'})
    assert_equal "\n\nDecember 25th, 2007\n", @s3_test.public_canonicalized_positional_headers
  end  
  
end