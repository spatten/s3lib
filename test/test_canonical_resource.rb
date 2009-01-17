require 'test/unit'
require File.join(File.dirname(__FILE__), 's3_authenticator_dev')

class S3AuthenticatorCanonicalResourceTest < Test::Unit::TestCase
  
  def setup
    @s3_test = S3Lib::AuthenticatedRequest.new
  end

  def test_forward_slash_is_always_added
    @s3_test.make_authenticated_request(:get, '')
    assert_match /^\//, @s3_test.canonicalized_resource
  end
  
  def test_bucket_name_in_uri_should_get_passed_through
    @s3_test.make_authenticated_request(:get, 'my_bucket')
    assert_match /^\/my_bucket/, @s3_test.canonicalized_resource
  end
    
  def test_canonicalized_resource_should_include_uri
    @s3_test.make_authenticated_request(:get, 'my_bucket/vampire.jpg')
    assert_match /vampire.jpg$/, @s3_test.canonicalized_resource
  end  
  
  def test_canonicalized_resource_should_include_sub_resource
    @s3_test.make_authenticated_request(:get, 'my_bucket/vampire.jpg?torrent')
    assert_match /vampire.jpg\?torrent$/, @s3_test.canonicalized_resource    
  end
  
  def test_bucket_name_with_virtual_hosting
    @s3_test.make_authenticated_request(:get, '/', {'host' => 'some_bucket.s3.amazonaws.com'})
    assert_match /some_bucket\//, @s3_test.canonicalized_resource
    assert_no_match /s3.amazonaws.com/, @s3_test.canonicalized_resource
  end
  
  def test_bucket_name_with_cname_virtual_hosting
    @s3_test.make_authenticated_request(:get, '/', {'host' => 'some_bucket.example.com'})
    assert_match /^\/some_bucket.example.com/, @s3_test.canonicalized_resource
  end
  
  def test_bucket_name_is_lowercase_with_virtual_hosting
    @s3_test.make_authenticated_request(:get, '/', {'host' => 'Some_Bucket.s3.amazonaws.com'})
    assert_match /some_bucket/, @s3_test.canonicalized_resource
  end
  
  def test_bucket_name_is_lowercase_with_cname_virtual_hosting
    @s3_test.make_authenticated_request(:get, '/', {'host' => 'Some_Bucket.example.com'})
    assert_match /some_bucket.example.com/, @s3_test.canonicalized_resource
  end  

  
end