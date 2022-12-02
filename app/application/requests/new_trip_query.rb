# frozen_string_literal: true

require 'base64'
require 'dry/monads'
require 'json'

module ComfyWings
  module Request
    # From Object for Trip Query from frontend user
    class NewTripQuery
      include Dry::Monads::Result::Mixin

      def initialize(params)
        @params = params
      end

      # Use in API to parse incoming list requests
      def call
        Success(
          JSON.parse(@params)
        )
      rescue StandardError
        Failure(
          Response::ApiResult.new(
            status: :bad_request,
            message: 'Unacceptable Data Format'
          )
        )
      end
    end
  end
end
