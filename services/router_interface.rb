require 'rubygems'
require 'sinatra'
require 'json'
require 'redis'

redis = Redis.new

# All results are json encoded and supply a boolean result and error hash.

# return all api keys in the system
get "/keys" do
  res = (redis.smembers 'api_keys')
  content_type :json
  {:result => res, :errors => {}}.to_json
end

# validate the existance of an api key
get "/keys/:key" do
  res = redis.sismember 'api_keys', params[:key]
  content_type :json
  (res ? {:result => res, :errors => {}} : {:result => false, :errors => {:key => 'does not exist'}}).to_json
end

# create a new api key
post "/keys" do
  content_type :json
  if params[:key]
    res = redis.sadd 'api_keys', params[:key]
    {:result => res, :errors => {}}.to_json
  else
    {:result => false, :errors => {:key => 'not provided'}}.to_json
  end
end

# delete a specific api key
delete "/keys/:key" do
  content_type :json
  if params[:key]
    res = redis.srem 'api_keys', params[:key]
    {:result => res, :errors => {}}.to_json
  else
    {:result => false, :errors => {:key => 'not provided'}}.to_json
  end 
end


get "/routes" do
end

post "/routes" do
end

delete "/routes" do
end


# remove an existing api key
# delete "/keys" do
#   if params[:key]
#     redis.del 'api_key'
#   end
# end

# get "/" do
#   {:something => 'else'}.to_json
# end
# 
# get "/info" do
#   {:keys => 0, :routes => 0}
# end
# 
# 
# get "/routes" do
#   redis.
#   {:result => redis.get(params[:route])}.to_json
# end
# 
# post "/routes/register" do
#   redis.sadd
#   {}.to_json
# end
# 
# delete "/routes/remove" do
#   {}.to_json
# end