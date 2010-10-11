require 'test_helper'

class RouterInterfaceTest < Test::Unit::TestCase
  include Rack::Test::Methods
  
  @@db = Mongo::Connection.new.db('api_router')
  
  def setup
    @keys = @@db.collection('keys')
    @keys.remove
    @keys.insert(:key => 'test1')
    
    @routes = @@db.collection('routes')
    @routes.remove
    @routes.insert(:location => '127.0.0.1:8001', :version => 1, :route => '/example/path')
    @routes.insert(:location => '127.0.0.1:8010', :version => 2, :route => '/example/path')
  end
  
  def app
    Sinatra::Application
  end
  
  def parse_response
    JSON.parse(last_response.body)
  end
  
  def last_errors
    parse_response['errors']
  end
  
  def last_result
    parse_response['result']
  end
  
  def test_key_list
    get '/keys'
    assert_equal({}, last_errors)
    assert_equal([{'key' => 'test1'}], last_result)
    assert last_response.ok?
  end

  def test_insert_key
    post '/keys', :key => 'test2', :version => 1
    assert last_response.ok?
    assert_equal({}, last_errors)
    assert_equal(true, last_result)
  end
  
  def test_improperly_insert_key
    post '/keys', :blah => 'foo'
    assert last_response.ok?
    assert_equal({'key' => 'not provided'}, last_errors)
    assert_equal(false, last_result)
  end
  
  def test_verify_key
    get '/keys/test1'
    assert last_response.ok?
    assert_equal({}, last_errors)
    assert_equal(true,last_result)
  end
  
  def test_unverified_key
    get '/keys/nonexistant'
    assert last_response.ok?
    assert_equal(false, last_result)
    assert_equal({'key' => 'does not exist'}, last_errors)
  end

  def test_remove_key
    delete '/keys/test1'
    assert last_response.ok?
    assert_equal(true, last_result)
    assert_equal({}, last_errors)
  end
  
  def test_route_index
    get '/routes'
    assert last_response.ok?
    assert_equal([{"route"=>"/example/path", "location"=>"127.0.0.1:8001", "version"=>1},
     {"route"=>"/example/path", "location"=>"127.0.0.1:8010", "version"=>2}], last_result)
    assert_equal({}, last_errors)
  end
  
  def test_proper_route_insertion
    post '/routes', :location => '127.0.0.1', :route => '/test/this', :version => 42
    assert last_response.ok?
    assert_equal(true, last_result)
    assert_equal({}, last_errors)
  end

  def test_route_removal
    delete '/routes', :location => '127.0.0.1', :route => '/test/this', :version => 42
    assert last_response.ok?
    assert_equal(true, last_result)
    assert_equal({}, last_errors)
  end
  
  def test_invalid_route_removal
    delete '/routes', :blah => 999
    assert last_response.ok?
    assert_equal(false, last_result)
    assert_equal({'route' => 'not removed'}, last_errors)
  end
  
end