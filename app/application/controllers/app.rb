# frozen_string_literal: true

require 'roda'
require 'slim'
require 'slim/include'

# Remove this line once integrated with api
require 'yaml'

module ComfyWings
  # Main controller class for ComfyWings
  class App < Roda
    plugin :halt
    plugin :flash
    plugin :all_verbs # enable other HTML verbs such as PUT/DELETE
    plugin :render, engine: 'slim', views: 'app/presentation/views_html'
    plugin :assets, path: 'app/presentation/assets',
                    css: 'style.css'
    plugin :common_logger, $stderr

    route do |routing|
      routing.assets # load CSS
      response['Content-Type'] = 'text/html; charset=utf-8'

      # GET /
      routing.root do
        currency_list = Repository::For.klass(Entity::Currency).all
        view 'home', locals: { currencies: currency_list }
      end

      routing.is 'flight' do
        # POST /flight
        routing.post do
          trip_request = Forms::NewTripQuery.new.call(routing.params)
          trips = Service::FindTrips.new.call(trip_request)
          if trips.failure?
            flash[:error] = trips.failure
            response.status = 400
            routing.redirect '/'
          end
          view 'flight', locals:
          {
            trips: trips.value!,
            trip_request: trip_request.values
          }
        end
      end

      routing.on 'api' do
        routing.on 'trips' do
          routing.on String do |query_code|
            # GET /trips/{query_code}
            routing.get do
              result = Service::SearchTrips.new.call(query_code)
              puts query_code
              if result.failure?
                failed = Representer::HttpResponse.new(result.failure)
                routing.halt failed.http_status_code, failed.to_json
              end

              http_response = Representer::HttpResponse.new(result.value!)
              response.status = http_response.http_status_code

              Representer::Trips.new(
                result.value!.message
              ).to_json
            end
          end
        end
      end
    end
  end
end
