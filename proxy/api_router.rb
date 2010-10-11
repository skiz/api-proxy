require 'rubygems'
require 'redis'
require 'json'

class ApiRouter
  
  self.redis = Redis.new
  
  
  # LOCATIONS = [
  #   {:method => '/users/create', :version => '1', :location => '192.168.1.150:8001'},
  #   {:method => '/users/create', :version => '2', :location => '192.168.1.160:8020'}
  # ].freeze
  # 
  # KEYS = [
  #   {:key => 'test1', :version => '1'},
  #   {:key => 'test2', :version => '2'}
  # ].freeze

  def self.lookup(method, key, ver)
    if !KEYS.find{|k| k[:key] == key && k[:version] == ver}
      {:close => 'HTTP/1.1 403 Forbidden'}
    elsif loc = LOCATIONS.find{|l| l[:version] == ver && l[:method] == method}
      {:remote => loc[:location], :connect_timeout => 1.0}
    else
      {:close => 'HTTP/1.1 501 Not Implemeted'}
    end
  end
end

proxy_connect_error do |remote|
  {:close => 'HTTP/1.1 503 Service Unavailable'}
end

proxy do |data|
  if data =~ %r{(GET|PUT|POST|DELETE) (.*)\?key=(\w+)&ver=(\d+)|\?ver=(\d+)&key=(\w+)}
    method = $2
    key = $3 || $6
    ver = $4 || $5
    ApiRouter.lookup(method, key, ver)
  else
    {:noop => true}
  end
end
