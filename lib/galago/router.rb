module Galago
  class Router
    require 'galago/router/dsl'
    require 'galago/router/errors'
    require 'galago/router/path'
    require 'galago/router/route'
    require 'galago/router/version'

    REQUEST_METHODS = [
      "GET",
      "PATCH",
      "POST",
      "PUT",
      "DELETE"
    ]

    attr_reader :routes

    def initialize(&block)
      @routes = REQUEST_METHODS.each_with_object({}) do |request_method, routes|
        routes[request_method] = []
        routes
      end

      Router::DSL.new(self, block) if block_given?
    end

    def add_route(request_method, path, application)
      route = Route.new(request_method, path, application)
      routes[route.request_method] << route
    end

    def has_route?(request_method, path)
      find_route(request_method, path) ? true : false
    end

    def call(env)
      if route = find_route(env['REQUEST_METHOD'], env['PATH_INFO'])
        route.call(env)
      else
        Rack::Response.new("Not Found", 404).finish
      end
    end

    private

    def find_route(request_method, path)
      routes = routes_for_request_method(request_method)
      route = routes.detect { |route| route.recognizes_path?(path) }
    end

    def routes_for_request_method(request_method)
      routes.fetch(request_method.to_s.upcase) do
        raise RequestMethodInvalid.new(request_method)
      end
    end

  end
end
