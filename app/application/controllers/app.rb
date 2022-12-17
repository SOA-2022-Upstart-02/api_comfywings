# frozen_string_literal: true

require 'roda'

# Remove this line once integrated with api
require 'yaml'

module ComfyWings
  # Main controller class for ComfyWings
  class App < Roda
    plugin :halt
    plugin :caching
    plugin :all_verbs # enable other HTML verbs such as PUT/DELETE
    plugin :common_logger, $stderr

    # rubocop:disable Metrics/BlockLength
    route do |routing|
      response['Content-Type'] = 'application/json'

      # GET /
      routing.root do
        message = "ComfyWings API v1 at /api/v1/ in #{App.environment} mode."

        result_response = Representer::HttpResponse.new(
          Response::ApiResult.new(status: :ok, message:)
        )

        response.status = result_response.http_status_code
        result_response.to_json
      end

      routing.on 'api' do # rubocop:disable Metrics/BlockLength
        routing.is 'currency/all' do
          routing.get do
            response.cache_control public: true, max_age: 300
            result = Service::RetrieveCurrencies.new.call(routing.params)
            if result.failure?
              failed = Representer::HttpResponse.new(result.failure)
              routing.halt failed.http_status_code, failed.to_json
            end
  
            http_response = Representer::HttpResponse.new(result.value!)
            response.status = http_response.http_status_code
  
            Representer::CurrenciesList.new(
              result.value!.message
            ).to_json
          end
        end
  
        routing.on 'airport' do
          routing.on String do |iata_code|
            # GET /airport/{iata_code}
            routing.get do
              result = Service::SearchAirport.new.call(iata_code)
              if result.failure?
                failed = Representer::HttpResponse.new(result.failure)
                routing.halt failed.http_status_code, failed.to_json
              end
  
              http_response = Representer::HttpResponse.new(result.value!)
              response.status = http_response.http_status_code
  
              Representer::Airport.new(
                result.value!.message
              ).to_json
            end
          end
        end
  
        routing.on 'airportlist' do
          routing.on String do |iata_code_letter|
            # GET /airport/{iata_code}
            routing.get do
              result = Service::GroupAirports.new.call(iata_code_letter)
              if result.failure?
                failed = Representer::HttpResponse.new(result.failure)
                routing.halt failed.http_status_code, failed.to_json
              end
  
              http_response = Representer::HttpResponse.new(result.value!)
              response.status = http_response.http_status_code
  
              Representer::AirportList.new(
                result.value!.message
              ).to_json
            end
          end
        end
        routing.on 'trips' do
          routing.on String do |query_code|
            # GET /trips/{query_code}
            routing.get do
              result = Service::SearchTrips.new.call(query_code)
              if result.failure?
                failed = Representer::HttpResponse.new(result.failure)
                routing.halt failed.http_status_code, failed.to_json
              end
              http_response = Representer::HttpResponse.new(result.value!)
              response.status = http_response.http_status_code

              Representer::TripsList.new(
                result.value!.message
              ).to_json
            end
          end
        end

        routing.on 'trip_query' do
          # POST /trip_query
          routing.post do
            trip_query = Request::NewTripQuery.new(routing.body.read)
            result = Service::AddTripQuery.new.call(trip_query)

            if result.failure?
              failed = Representer::HttpResponse.new(result.failure)
              routing.halt failed.http_status_code, failed.to_json
            end

            http_response = Representer::HttpResponse.new(result.value!)
            response.status = http_response.http_status_code
            Representer::TripQuery.new(result.value!.message).to_json
          end
        end
      end
      # rubocop:enable Metrics/BlockLength
    end
  end
end
