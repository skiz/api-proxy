# A simple sinatra application that provides a restful API interface with json
# based responses to handle managing routes externally. Currently it supports
# the following methods, but however does not current support proper http 
# response codes;
#
# = Response Structure
# All responses are provided as json, and provide 2 parts to the response.
#   1. The 'result' - Generally true/false, but also may be a single json encoded object.
#      
#
#   2. The 'errors' - This hash will be empty for successful requests, or contain more info on failures.
#
# = Supported 'Key' Interface
#
# == GET /keys
# * provides a list of all keys currently configured in the system
#
# == POST /keys
# * create a new API key in the database (requires key parameter)
#
# == GET /keys/:key
# * verifies that an API key exists (via key param in request url)
#
#
#
# = Supported 'Route' Interface
#
# == GET /routes
# * provides a list of all routes currently configured in the system
#
# == POST /routes
# * creates a new route in the database (requires location, route, version as post parameters)
#
# == DELETE /routes
# * removes a route from the database (requires location, route, version as post parameters)
#
require 'rubygems'
require 'sinatra'
require 'json'
require 'mongo'

# mongo as a quick example store
db     = Mongo::Connection.new.db('api_router')
keys   = db.collection('keys')
routes = db.collection('routes')

# return all api keys in the system
get "/keys" do
  res = keys.find.map{|k| {'key' => k['key']} }
  content_type :json
  {:result => res, :errors => {}}.to_json
end

# create a new api key
post "/keys" do
  content_type :json
  if params[:key]
    if keys.insert({:key => params[:key]})
      {:result => true, :errors => {}}.to_json
    else
      {:result => false, :errors => {:key => 'not added'}}.to_json
    end
  else
    {:result => false, :errors => {:key => 'not provided'}}.to_json
  end
end

# validate the existance of an api key
get "/keys/:key" do
  res = keys.find('key' => params[:key]).first
  content_type :json
  (res ? {:result => true, :errors => {}} : {:result => false, :errors => {:key => 'does not exist'}}).to_json
end

# delete a specific api key
delete "/keys/:key" do
  content_type :json
  if params[:key]
    res = keys.remove(:key => params[:key])
    {:result => true, :errors => {}}.to_json
  else
    {:result => false, :errors => {:key => 'not provided'}}.to_json
  end
end

# get a full list of routes with their versions
get '/routes' do
  res = routes.find.map{|r| {'location' => r['location'], 'version' => r['version'], 'route' => r['route']} }
  content_type :json
  {:result => res, :errors => {}}.to_json  
end

# register a new route
post '/routes' do
  if params[:location] && params[:version] && params[:route] &&
     routes.insert({:location => params[:location], :version => params[:version], :route => params[:route]})
      {:result => true, :errors => {}}.to_json
  else
    {:result => false, :errors => {:route => 'not added'}}.to_json
  end
end

# delete an existing route
delete '/routes' do
  if params[:location] && params[:version] && params[:route]
    res = routes.remove({:location => params[:location], :version => params[:version], :route => params[:route]})
    {:result => true, :errors => {}}.to_json
  else
    {:result => false, :errors => {:route => 'not removed'}}.to_json
  end
end