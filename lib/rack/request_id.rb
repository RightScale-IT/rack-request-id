require 'securerandom'

module Rack
  class RequestId
    def initialize(app)
      @app = app
    end

    def call(env)
      request_id =  external_request_id(env) || internal_request_id
      
      Thread.current[:request_id] = request_id

      Thread.current['action_dispatch.request_id'] = request_id

      env["action_dispatch.request_id"] = request_id

      env['HTTP_X_REQUEST_ID'] = request_id
      
      @app.call(env).tap { |_status, headers, _body| headers["X-Request-Id"] = request_id }
    end
    
    private
      def external_request_id(env)
        if request_id = env["HTTP_X_REQUEST_ID"].presence
          request_id.gsub(/[^\w\-]/, "").first(255)
        end
      end

      def internal_request_id
        SecureRandom.uuid
      end
      
  end
end
