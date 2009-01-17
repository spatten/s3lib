require 'test/unit'
require File.join(File.dirname(__FILE__), '../lib/s3_authenticator')

class S3AuthenticatorAmazonHeadersTest < Test::Unit::TestCase
  
  def setup
    @s3_test = S3Lib::AuthenticatedRequest.new
  end
  
  def test_amazon_headers_should_remove_non_amazon_headers
    @s3_test.make_authenticated_request(:get, '', {'content-type' => 'content', 
                                                   'some-other-header' => 'other',
                                                   'x-amz-meta-one' => 'one',
                                                   'x-amz-meta-two' => 'two'})
    headers = @s3_test.canonicalized_amazon_headers
    assert_no_match /other/, headers
    assert_no_match /content/, headers
  end
  
  def test_amazon_headers_should_keep_amazon_headers
    @s3_test.make_authenticated_request(:get, '', {'content-type' => 'content', 
                                                   'some-other-header' => 'other',
                                                   'x-amz-meta-one' => 'one',
                                                   'x-amz-meta-two' => 'two'})
    headers = @s3_test.canonicalized_amazon_headers    
    assert_match /x-amz-meta-one/, headers
    assert_match /x-amz-meta-two/, headers
  end
  
  def test_amazon_headers_should_be_lowercase
    @s3_test.make_authenticated_request(:get, '', {'content-type' => 'content', 
                                                   'some-other-header' => 'other',
                                                   'X-amz-meta-one' => 'one',
                                                   'x-Amz-meta-two' => 'two'})
    headers = @s3_test.canonicalized_amazon_headers    
    assert_match /x-amz-meta-one/, headers
    assert_match /x-amz-meta-two/, headers
  end
  
  def test_amazon_headers_should_be_alphabetized
    @s3_test.make_authenticated_request(:get, '', {'content-type' => 'content', 
                                                   'some-other-header' => 'other',
                                                   'X-amz-meta-one' => 'one',
                                                   'x-Amz-meta-two' => 'two',
                                                   'x-amz-meta-zed' => 'zed',
                                                   'x-amz-meta-alpha' => 'alpha'})
    headers = @s3_test.canonicalized_amazon_headers    
    assert_match /alpha.*one.*two.*zed/m, headers # /m on the reg-exp makes .* include newlines
  end
  
  def test_xamzdate_should_override_date_header
    @s3_test.make_authenticated_request(:get, '', {'date' => 'December 15, 2005', 'x-amz-date' => 'Tue, 27 Mar 2007 21:20:26 +0000'})
    headers = @s3_test.canonicalized_headers    
    assert_match /2007/, headers
    assert_no_match /2005/, headers
  end

  def test_xamzdate_should_override_capitalized_date_header
    @s3_test.make_authenticated_request(:get, '', {'date' => 'December 15, 2005', 'X-amz-date' => 'Tue, 27 Mar 2007 21:20:26 +0000'})
    headers = @s3_test.canonicalized_headers    
    assert_match /2007/, headers
    assert_no_match /2005/, headers
  end
  
  def test_leading_spaces_get_stripped_from_header_values
    @s3_test.make_authenticated_request(:get, '', {'x-amz-meta-one' => ' one with a leading space',
                                                   'x-Amz-meta-two' => ' two with a leading and trailing space '})
    headers = @s3_test.canonicalized_amazon_headers 
    assert_match /x-amz-meta-one:one with a leading space/, headers
    assert_match /x-amz-meta-two:two with a leading and trailing space /, headers 
  end
  
  def test_long_amazon_headers_should_get_unfolded
    @s3_test.make_authenticated_request(:get, '', {'x-amz-meta-one' => "A really long header\nwith multiple lines\nshould be unfolded."})
    headers = @s3_test.canonicalized_amazon_headers 
    assert_match /x-amz-meta-one:A really long header with multiple lines should be unfolded./, headers    
  end
  
  def test_values_as_arrays_should_be_joined_as_commas
     @s3_test.make_authenticated_request(:get, '', {'x-amz-mult' => ['a', 'b', 'c']})
     
     headers = @s3_test.canonicalized_amazon_headers
     assert_match /a,b,c/, headers
  end
  
end