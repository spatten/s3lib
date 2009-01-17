require 'test/unit'
require File.join(File.dirname(__FILE__), '..', 'lib', 's3lib')
include S3Lib

class S3AclTest < Test::Unit::TestCase
  
  SPATTEN_CANONICAL_ID = '9d92623ba6dd9d7cc06a7b8bcc46381e7c646f72d769214012f7e91b50c0de0f'
  SPATTEN_DESIGN_CANONICAL_ID = '2f29caa19cd40477cf8a840b6dc473463cbda95b7dc81a8d72118a42733a7661'
  SPATTEN_EMAIL = 'scott@spattendesign.com'
  
  def setup
    @bucket = Bucket.find('spatten_test_bucket')
    @object = @bucket['shoes']
    @bucket_acl = Acl.new('spatten_test_bucket')
  end
  
  def teardown
    @bucket_acl.clear_grants
    @bucket_acl.add_grant(:full_control, {:type => :canonical, :grantee => @bucket_acl.owner})
    @bucket_acl.set_grants
  end
  
  
  def test_acl_creation_with_bucket_object
    assert_nothing_raised{@bucket_acl = Acl.new(@bucket)}
  end
  
  def test_acl_can_instantiate_grants
    assert_nothing_raised {@bucket_acl.grants.inspect}
  end
  
  def test_add_grant_works
    old_length = @bucket_acl.grants.length    
    assert_nothing_raised do
      @bucket_acl.add_grant(:read, {:type => :all_s3})
      assert_equal old_length + 1, @bucket_acl.grants.length
    end
  end 

  def test_add_grant_by_canonical_id
    old_length = @bucket_acl.grants.length    
    assert_nothing_raised do
      @bucket_acl.add_grant(:read, {:type => :canonical, :grantee => SPATTEN_DESIGN_CANONICAL_ID})
      assert_equal old_length + 1, @bucket_acl.grants.length
    end    
    @bucket_acl.set_grants
    assert_equal old_length + 1, @bucket_acl.grants.length
    assert_equal :canonical, @bucket_acl.grants.last.type
    assert_equal SPATTEN_DESIGN_CANONICAL_ID, @bucket_acl.grants.last.grantee    
  end
  
  def test_add_grant_by_email
    old_length = @bucket_acl.grants.length    
    assert_nothing_raised do
      @bucket_acl.add_grant(:read, {:type => :email, :grantee => SPATTEN_EMAIL})
      assert_equal old_length + 1, @bucket_acl.grants.length
    end    
    @bucket_acl.set_grants
    assert_equal old_length + 1, @bucket_acl.grants.length
    assert_equal :canonical, @bucket_acl.grants.last.type
    assert_equal SPATTEN_DESIGN_CANONICAL_ID, @bucket_acl.grants.last.grantee
  end
  
  def test_add_grant_to_all_s3
    old_length = @bucket_acl.grants.length    
    assert_nothing_raised do
      @bucket_acl.add_grant(:read, {:type => :all_s3})
      assert_equal old_length + 1, @bucket_acl.grants.length
    end    
    @bucket_acl.set_grants
    assert_equal old_length + 1, @bucket_acl.grants.length    
  end
  
  def test_to_xml_includes_grant_xml
    assert_match "<Grant>", @bucket_acl.to_xml
  end
  
  def test_set_grants_works
    old_length = @bucket_acl.grants.length
    @bucket_acl.add_grant(:read, {:type => :all_s3})
    assert_nothing_raised {@bucket_acl.set_grants}
    assert_equal old_length + 1, @bucket_acl.grants.length
  end 
  
  def test_owner
    assert_equal SPATTEN_CANONICAL_ID, @bucket_acl.owner
  end
end