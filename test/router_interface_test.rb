require '../services/router_interface'
require 'test/unit'
require 'rack/test'
require 'json'

set :environment, :test

class RouterInterfaceTest < Test::Unit::TestCase
  include Rack::Test::Methods
  
  def setup
    @redis = Redis.new
    @redis.del 'api_keys'
    @redis.sadd'api_keys', 'test1'
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
    assert last_response.ok?
  end

  def test_insert_key
    post '/keys', :key => 'test2'
    assert last_response.ok?
    assert_equal({}, last_errors)
    assert_equal(true, last_result)
  end
  
  def test_improperly_insert_key
    post '/keys', :blah => 'foo'
    puts last_result
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
    get '/keys/nonexist'
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
  
end