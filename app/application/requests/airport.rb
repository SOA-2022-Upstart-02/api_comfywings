# frozen_string_literal: true

require 'dry/monads'
require 'json'

module ComfyWings
  module Requests
    # Airport form object
    class Airport
      include Dry::Monads::Result::Mixin

      def initialize(params)
        @params = params
      end

      # Use in API to parse incoming requests
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
