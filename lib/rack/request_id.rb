require 'securerandom'

module Rack
  class RequestId
    def initialize(app)
      @app = app
    end

    def call(env)
      request_id = env['HTTP_X_REQUEST_ID'] || SecureRandom.uuid

      # Used by some things
      Thread.current[:request_id] = request_id

      # Used by others
      Thread.current['action_dispatch.request_id'] = request_id

      status, headers, body = @app.call(env)
      headers['X-Request-Id'] ||= request_id
      env['HTTP_X_REQUEST_ID'] = request_id
      @app.call(env).tap { |_status, headers, _body| headers["X-Request-Id"] = request_id }
    end
  end
end
