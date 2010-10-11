require 'test_helper'

class ApiRouterTest < Test::Unit::TestCase

  @@db = Mongo::Connection.new.db('api_router')
  
  def setup
    @keys = @@db.collection('keys')
    @keys.remove
    @keys.insert(:key => 'test1')
    
    @routes = @@db.collection('routes')
    @routes.remove
    @routes.insert(:location => '127.0.0.1:8001', :version => 1, :route => '/example/path')
    @routes.insert(:location => '127.0.0.1:8010', :version => 2, :route => '/example/path')
    
    ApiRouter.routes = @@db.collection('routes')
    ApiRouter.keys   = @@db.collection('keys')
  end
  
  def test_set_key_collection
    keys = @@db.collection('keys')
    ApiRouter.keys = keys
    assert_equal(ApiRouter.keys, keys)
  end
  
  def test_set_route_collection
    routes = @@db.collection('routes')
    ApiRouter.routes = routes
    assert_equal(ApiRouter.routes, routes)
  end
  
  def test_proper_route_selection
    assert_equal ({:remote => '127.0.0.1:8001', :connect_timeout => 1.0}),
      ApiRouter.lookup('/example/path', 'test1', 1)
  end
  
  def test_lookup_fails_key
    assert_equal ({:close=>"HTTP/1.1 403 Forbidden"}),
      ApiRouter.lookup('/fail/whale', 'boobar', 3)
  end
  
  def test_lookup_fails_version
    assert_equal ({:close=>"HTTP/1.1 501 Not Implemented"}),
      ApiRouter.lookup('/fail/whale', 'test1', 3)
  end
  
  def test_lookup_fails_route
    assert_equal ({:close=>"HTTP/1.1 501 Not Implemented"}),
      ApiRouter.lookup('/example/path', 'test1', 3)
  end
    
end