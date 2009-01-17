require 'test/unit'
require File.join(File.dirname(__FILE__), 's3_authenticator_dev')

class S3AuthenticatorTest < Test::Unit::TestCase
  
  def setup
    # The id and secret key are non-working credentials from the S3 Developer's Guide 
    # See http://developer.amazonwebservices.com/connect/entry.jspa?externalID=123&categoryID=48
    ENV['AMAZON_ACCESS_KEY_ID'] = '0PN6J17HBGXHT7JJ3X82'
    ENV['AMAZON_SECRET_ACCESS_KEY'] = 'uV3F3YluFJax1cknvbcGwgjvx4QpvB+leU8dUj2o'
    @s3_test = S3Lib::AuthenticatedRequest.new
  end

  # See http://developer.amazonwebservices.com/connect/entry.jspa?externalID=123&categoryID=48
  def test_dg_sample_one
    @s3_test.make_authenticated_request(:get, '/photos/puppy.jpg', {'Host' => 'johnsmith.s3.amazonaws.com',
                                                                    'Date' => 'Tue, 27 Mar 2007 19:36:42 +0000'})
    expected_canonical_string = "GET\n\n\nTue, 27 Mar 2007 19:36:42 +0000\n/johnsmith/photos/puppy.jpg"
    assert_equal expected_canonical_string, @s3_test.canonical_string
    assert_equal "AWS 0PN6J17HBGXHT7JJ3X82:xXjDGYUmKxnwqr5KXNPGldn5LbA=", @s3_test.authorization_string    
  end

  # See http://developer.amazonwebservices.com/connect/entry.jspa?externalID=123&categoryID=48
  def test_dg_sample_two
    @s3_test.make_authenticated_request(:put, '/photos/puppy.jpg', {'Content-Type' => 'image/jpeg',
                                                                    'Content-Length' => '94328',
                                                                    'Host' => 'johnsmith.s3.amazonaws.com',
                                                                    'Date' => 'Tue, 27 Mar 2007 21:15:45 +0000'})
    expected_canonical_string = "PUT\n\nimage/jpeg\nTue, 27 Mar 2007 21:15:45 +0000\n/johnsmith/photos/puppy.jpg"
    assert_equal expected_canonical_string, @s3_test.canonical_string  
    assert_equal "AWS 0PN6J17HBGXHT7JJ3X82:hcicpDDvL9SsO6AkvxqmIWkmOuQ=", @s3_test.authorization_string  
  end

  def test_dg_sample_three
    @s3_test.make_authenticated_request(:get, '', {'prefix' => 'photos',
                                                   'max-keys' => '50',
                                                   'marker' => 'puppy',
                                                   'host' => 'johnsmith.s3.amazonaws.com',
                                                   'date' => 'Tue, 27 Mar 2007 19:42:41 +0000'})
    assert_equal "GET\n\n\nTue, 27 Mar 2007 19:42:41 +0000\n/johnsmith/", @s3_test.canonical_string
    assert_equal 'AWS 0PN6J17HBGXHT7JJ3X82:jsRt/rhG+Vtp88HrYL706QhE4w4=', @s3_test.authorization_string
  end 

  def test_dg_sample_four
    @s3_test.make_authenticated_request(:get, '?acl', {'host' => 'johnsmith.s3.amazonaws.com', 
                                                       'date' => 'Tue, 27 Mar 2007 19:44:46 +0000'})
  
    assert_equal "GET\n\n\nTue, 27 Mar 2007 19:44:46 +0000\n/johnsmith/?acl", @s3_test.canonical_string
    assert_equal 'AWS 0PN6J17HBGXHT7JJ3X82:thdUi9VAkzhkniLj96JIrOPGi0g=', @s3_test.authorization_string
  
  end

  def test_dg_sample_five
    @s3_test.make_authenticated_request(:delete, '/johnsmith/photos/puppy.jpg', 
                                                  {'User-Agent' => 'dotnet',
                                                   'host' => 's3.amazonaws.com',
                                                   'date' => 'Tue, 27 Mar 2007 21:20:27 +0000',
                                                   'x-amz-date' => 'Tue, 27 Mar 2007 21:20:26 +0000' })                                                   
    assert_equal "DELETE\n\n\n\nx-amz-date:Tue, 27 Mar 2007 21:20:26 +0000\n/johnsmith/photos/puppy.jpg", @s3_test.canonical_string
    assert_equal 'AWS 0PN6J17HBGXHT7JJ3X82:k3nL7gH3+PadhTEVn5Ip83xlYzk=', @s3_test.authorization_string
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
    expected_canonical_string =  "PUT\n4gJE4saaMU4BqNR0kLY+lw==\napplication/x-download\nTue, 27 Mar 2007 21:06:08 +0000\n" + 
                                 "x-amz-acl:public-read\nx-amz-meta-checksumalgorithm:crc32\nx-amz-meta-filechecksum:0x02661779\n" +
                                 "x-amz-meta-reviewedby:joe@johnsmith.net,jane@johnsmith.net\n/static.johnsmith.net/db-backup.dat.gz"
    assert_equal expected_canonical_string, @s3_test.canonical_string
    assert_equal 'AWS 0PN6J17HBGXHT7JJ3X82:C0FlOtU8Ylb9KDTpZqYkZPX91iI=', @s3_test.authorization_string
  end
  
end