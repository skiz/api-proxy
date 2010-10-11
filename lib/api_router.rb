require 'active_support/core_ext' # I'm lazy

# The ApiRouter provides the ability to process a proxyMachine request and then
# depending on the authorization and routing of the intended API request, it will
# then create a transparent proxy connection to the routed services, or can also
# inject a HTTP response and immediately close the connection with proper status codes.
#
#   TODO: Add authorization, deprecation warnings, ip limiting, stat counters, and logging
class ApiRouter
  
  cattr_accessor :keys, :routes
  
  class << self
    
    # Look up a specific route and return a proxyMachine supported response.
    # This also validates the API key before allowing any additional processing.
    def lookup(route, key, version)
      return {:close => 'HTTP/1.1 403 Forbidden'} unless valid_key?(key)
      if loc = locate_route(route, version)
        {:remote => loc['location'], :connect_timeout => 1.0}
      else
        {:close => 'HTTP/1.1 501 Not Implemented'}
      end
    end
    
    protected
    
    def valid_key?(key) #:nodoc:
      self.keys.find(:key => key).count > 0
    end
    
    def locate_route(route, version) #:nodoc:
      self.routes.find(:route => route, :version => version).first
    end
    
  end
end
