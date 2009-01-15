require 'test/unit'
require File.join(File.dirname(__FILE__), '../s3_authenticator')

# Make private methods and attributes public so that you can test them
module S3Lib
  class AuthenticatedRequest
  
    attr_reader :bucket, :headers  
  
    def initialize()
    
    end
  
    def public_canonicalized_resource
      canonicalized_resource
    end
  
    def public_canonicalized_headers
      canonicalized_headers
    end  
  
    def public_canonicalized_positional_headers
      canonicalized_positional_headers
    end
  
    def public_canonicalized_amazon_headers
      canonicalized_amazon_headers
    end
  
    def public_canonical_string
      canonical_string
    end
  
    def public_authorization_string
      authorization_string
    end
  
    # Over-ride RestOpenURI#open
    def open(uri, headers)
      {:uri => uri, :headers => headers}
    end
  
  end  
end


class S3AuthenticatorTest < Test::Unit::TestCase
  
  def setup
    # The id and secret key are non-working credentials from the S3 Developer's Guide 
    # See http://developer.amazonwebservices.com/connect/entry.jspa?externalID=123&categoryID=48
    ENV['AMAZON_ACCESS_KEY_ID'] = '0PN6J17HBGXHT7JJ3X82'
    ENV['AMAZON_SECRET_ACCESS_KEY'] = 'uV3F3YluFJax1cknvbcGwgjvx4QpvB+leU8dUj2o'
    @s3_test = S3Lib::AuthenticatedRequest.new
  end
  
  def test_http_verb_is_uppercase
    @s3_test.make_authenticated_request(:get, '/', {'host' => 's3.amazonaws.com'})
    assert_match /^GET\n/, @s3_test.canonical_string
  end
  
  def test_bucket_name_is_correct_with_virtual_hosting
    @s3_test.make_authenticated_request(:get, '/', {'host' => 'some_bucket.s3.amazonaws.com'})
    assert_equal 'some_bucket/', @s3_test.bucket
  end
  
  def test_bucket_name_is_correct_with_cname_virtual_hosting
    @s3_test.make_authenticated_request(:get, '/', {'host' => 'some_bucket.example.com'})
    assert_equal 'some_bucket.example.com/', @s3_test.bucket    
  end
  
  def test_bucket_name_is_lowercase_with_virtual_hosting
    @s3_test.make_authenticated_request(:get, '/', {'host' => 'Some_Bucket.s3.amazonaws.com'})
    assert_equal 'some_bucket/', @s3_test.bucket    
  end
  
  def test_bucket_name_is_lowercase_with_cname_virtual_hosting
    @s3_test.make_authenticated_request(:get, '/', {'host' => 'Some_Bucket.example.com'})
    assert_equal 'some_bucket.example.com/', @s3_test.bucket    
  end  
  
  def test_forward_slash_is_always_added
    @s3_test.make_authenticated_request(:get, '')
    assert_match /^\//, @s3_test.public_canonicalized_resource
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
  
  def test_positional_headers_with_no_headers_should_have_date_defined
    @s3_test.make_authenticated_request(:get, '' )
    date = @s3_test.headers['date']
    assert_equal "\n\n#{date}\n", @s3_test.public_canonicalized_positional_headers      
  end
  
  def test_amazon_headers_should_remove_non_amazon_headers
    @s3_test.make_authenticated_request(:get, '', {'content-type' => 'content', 
                                                   'some-other-header' => 'other',
                                                   'x-amz-meta-one' => 'one',
                                                   'x-amz-meta-two' => 'two'})
    headers = @s3_test.public_canonicalized_amazon_headers
    assert_no_match /other/, headers
    assert_no_match /content/, headers
  end
  
  def test_amazon_headers_should_keep_amazon_headers
    @s3_test.make_authenticated_request(:get, '', {'content-type' => 'content', 
                                                   'some-other-header' => 'other',
                                                   'x-amz-meta-one' => 'one',
                                                   'x-amz-meta-two' => 'two'})
    headers = @s3_test.public_canonicalized_amazon_headers    
    assert_match /x-amz-meta-one/, headers
    assert_match /x-amz-meta-two/, headers
  end
  
  def test_amazon_headers_should_be_lowercase
    @s3_test.make_authenticated_request(:get, '', {'content-type' => 'content', 
                                                   'some-other-header' => 'other',
                                                   'X-amz-meta-one' => 'one',
                                                   'x-Amz-meta-two' => 'two'})
    headers = @s3_test.public_canonicalized_amazon_headers    
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
    headers = @s3_test.public_canonicalized_amazon_headers    
    assert_match /alpha.*one.*two.*zed/m, headers # /m on the reg-exp makes .* include newlines
  end
  
  def test_xamzdate_should_override_date_header
    @s3_test.make_authenticated_request(:get, '', {'date' => 'December 15, 2005', 'x-amz-date' => 'Tue, 27 Mar 2007 21:20:26 +0000'})
    headers = @s3_test.public_canonicalized_headers    
    assert_match /2007/, headers
    assert_no_match /2005/, headers
  end

  def test_xamzdate_should_override_capitalized_date_header
    @s3_test.make_authenticated_request(:get, '', {'date' => 'December 15, 2005', 'X-amz-date' => 'Tue, 27 Mar 2007 21:20:26 +0000'})
    headers = @s3_test.public_canonicalized_headers    
    assert_match /2007/, headers
    assert_no_match /2005/, headers
  end
  
  def test_leading_spaces_get_stripped_from_header_values
    @s3_test.make_authenticated_request(:get, '', {'x-amz-meta-one' => ' one with a leading space',
                                                   'x-Amz-meta-two' => ' two with a leading and trailing space '})
    headers = @s3_test.public_canonicalized_amazon_headers 
    assert_match /x-amz-meta-one:one with a leading space/, headers
    assert_match /x-amz-meta-two:two with a leading and trailing space /, headers 
  end
  
  def test_values_as_arrays_should_be_joined_as_commas
     @s3_test.make_authenticated_request(:get, '', {'x-amz-mult' => ['a', 'b', 'c']})
     
     headers = @s3_test.public_canonicalized_amazon_headers
     assert_match /a,b,c/, headers
  end
  
  def test_date_should_be_added_if_not_passed_in
    @s3_test.make_authenticated_request(:get, '')
    assert @s3_test.headers.has_key?('date')
  end
  
  # See http://developer.amazonwebservices.com/connect/entry.jspa?externalID=123&categoryID=48
  def test_dg_sample_one
    @s3_test.make_authenticated_request(:get, '/photos/puppy.jpg', {'Host' => 'johnsmith.s3.amazonaws.com',
                                                                    'Date' => 'Tue, 27 Mar 2007 19:36:42 +0000'})
    assert_equal 'johnsmith/', @s3_test.bucket
    expected_canonical_string = "GET\n\n\nTue, 27 Mar 2007 19:36:42 +0000\n/johnsmith/photos/puppy.jpg"
    assert_equal expected_canonical_string, @s3_test.public_canonical_string
    assert_equal "AWS 0PN6J17HBGXHT7JJ3X82:xXjDGYUmKxnwqr5KXNPGldn5LbA=", @s3_test.public_authorization_string    
  end
  
  # See http://developer.amazonwebservices.com/connect/entry.jspa?externalID=123&categoryID=48
  def test_dg_sample_two
    @s3_test.make_authenticated_request(:put, '/photos/puppy.jpg', {'Content-Type' => 'image/jpeg',
                                                                    'Content-Length' => '94328',
                                                                    'Host' => 'johnsmith.s3.amazonaws.com',
                                                                    'Date' => 'Tue, 27 Mar 2007 21:15:45 +0000'})
    assert_equal 'johnsmith/', @s3_test.bucket
    expected_canonical_string = "PUT\n\nimage/jpeg\nTue, 27 Mar 2007 21:15:45 +0000\n/johnsmith/photos/puppy.jpg"
    assert_equal expected_canonical_string, @s3_test.public_canonical_string  
    assert_equal "AWS 0PN6J17HBGXHT7JJ3X82:hcicpDDvL9SsO6AkvxqmIWkmOuQ=", @s3_test.public_authorization_string  
  end
  
  def test_dg_sample_three
    @s3_test.make_authenticated_request(:get, '', {'prefix' => 'photos',
                                                   'max-keys' => '50',
                                                   'marker' => 'puppy',
                                                   'host' => 'johnsmith.s3.amazonaws.com',
                                                   'date' => 'Tue, 27 Mar 2007 19:42:41 +0000'})
    assert_equal 'johnsmith/', @s3_test.bucket                                                   
    assert_equal "GET\n\n\nTue, 27 Mar 2007 19:42:41 +0000\n/johnsmith/", @s3_test.public_canonical_string
    assert_equal 'AWS 0PN6J17HBGXHT7JJ3X82:jsRt/rhG+Vtp88HrYL706QhE4w4=', @s3_test.public_authorization_string
  end 
  
  def test_dg_sample_four
    @s3_test.make_authenticated_request(:get, '?acl', {'host' => 'johnsmith.s3.amazonaws.com', 
                                                       'date' => 'Tue, 27 Mar 2007 19:44:46 +0000'})
    
    assert_equal "GET\n\n\nTue, 27 Mar 2007 19:44:46 +0000\n/johnsmith/?acl", @s3_test.public_canonical_string
    assert_equal 'AWS 0PN6J17HBGXHT7JJ3X82:thdUi9VAkzhkniLj96JIrOPGi0g=', @s3_test.public_authorization_string
    
  end
  
  def test_dg_sample_five
    @s3_test.make_authenticated_request(:delete, '/johnsmith/photos/puppy.jpg', 
                                                  {'User-Agent' => 'dotnet',
                                                   'host' => 's3.amazonaws.com',
                                                   'date' => 'Tue, 27 Mar 2007 21:20:27 +0000',
                                                   'x-amz-date' => 'Tue, 27 Mar 2007 21:20:26 +0000' })                                                   
    assert_equal "DELETE\n\n\n\nx-amz-date:Tue, 27 Mar 2007 21:20:26 +0000\n/johnsmith/photos/puppy.jpg", @s3_test.public_canonical_string
    assert_equal 'AWS 0PN6J17HBGXHT7JJ3X82:k3nL7gH3+PadhTEVn5Ip83xlYzk=', @s3_test.public_authorization_string
  end   
  
  def test_dg_sample_six
    @s3_test.make_authenticated_request(:put,    '/db-backup.dat.gz', 
                                                  {'User-Agent' => 'curl/7.15.5',
                                                   'host' => 'static.johnsmith.net:8080',
                                                   'date' => 'Tue, 27 Mar 2007 21:06:08 +0000',
                                                   'x-amz-acl' => 'public-read',
                                                   'content-type' => 'application/x-download',
                                                   'Content-MD5' => '4gJE4saaMU4BqNR0kLY+lw==',
                                                   'X-Amz-Meta-ReviewedBy' => ['joe@johnsmith.net', 'jane@johnsmith.net'],
                                                   'X-Amz-Meta-FileChecksum' => '0x02661779',
                                                   'X-Amz-Meta-ChecksumAlgorithm' => 'crc32',
                                                   'Content-Disposition' => 'attachment; filename=database.dat',
                                                   'Content-Encoding' => 'gzip',
                                                   'Content-Length' => '5913339' })
    assert_equal 'static.johnsmith.net/', @s3_test.bucket                                              
    expected_canonical_string =  "PUT\n4gJE4saaMU4BqNR0kLY+lw==\napplication/x-download\nTue, 27 Mar 2007 21:06:08 +0000\n" + 
                                 "x-amz-acl:public-read\nx-amz-meta-checksumalgorithm:crc32\nx-amz-meta-filechecksum:0x02661779\n" +
                                 "x-amz-meta-reviewedby:joe@johnsmith.net,jane@johnsmith.net\n/static.johnsmith.net/db-backup.dat.gz"
    assert_equal expected_canonical_string, @s3_test.public_canonical_string
    assert_equal 'AWS 0PN6J17HBGXHT7JJ3X82:C0FlOtU8Ylb9KDTpZqYkZPX91iI=', @s3_test.public_authorization_string
  end  
  
  def test_url_has_http_on_it
    request = @s3_test.make_authenticated_request(:get, '')
    assert_match /^http:\/\//, request[:uri]
  end
  
  def test_url_is_sane
    request = @s3_test.make_authenticated_request(:get, 'photos')
    assert_equal 'http://s3.amazonaws.com/photos', request[:uri]
  end

  
end