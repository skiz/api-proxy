# This is the proxymachine configuration file that processes HTTP requests via
# the ApiRouter mechanism. Currently it just sets up a mongo connection and 
# processes the requests based on the version and key parameters in the url.
#
# If the request is not in the proper format, it will return a "400 Bad Request" response.
# If the request is able to be processed, it will then be passed to the ApiRouter for 
# further processing.
#
# e.g. 
#   POST /mgmt/create_context&key=test123&version=43
#
#
# proxymachine -c $0 -p PORTNUM
#
require 'rubygems'
require 'mongo'
require 'api_router'

db = Mongo::Connection.new.db('api_router')

ApiRouter.routes = db.collection('routes')
ApiRouter.keys   = db.collection('keys')

proxy do |data|
  if data =~ %r{(GET|PUT|POST|DELETE) (.*)\?key=(\w+)&version=(\d+)|\?version=(\d+)&key=(\w+)}
    route = $2
    key = $3 || $6
    ver = $4 || $5
    ApiRouter.lookup(route, key, ver)
  else
    {:close => 'HTTP/1.1 400 Bad Request'}
  end
end

proxy_connect_error do |remote|
  {:close => 'HTTP/1.1 503 Service Unavailable'}
end
