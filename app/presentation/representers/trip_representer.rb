# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'flight_representer'

module ComfyWings
  module Representer
    # Represent a Trip as Json
    class Trip < Roar::Decorator
      include Roar::JSON
      include Roar::Hypermedia
      include Roar::Decorator::HypermediaConsumer

      property :id
      property :query_id
      property :currency                 # TODO: extend: Representer::Currency, class: OpenStruct
      property :origin                   # TODO: extend: Representer::Airport, class: OpenStruct
      property :destination              # TODO: extend: Representer::Airport, class: OpenStruct
      property :outbound_duration_form
      property :outbound_departure_time
      property :outbound_arrival_time
      property :inbound_duration_form
      property :inbound_departure_time
      property :inbound_arrival_time
      collection :outbound_flights, extend: Representer::Flight, class: OpenStruct
      collection :inbound_flights, extend: Representer::Flight, class: OpenStruct

      # link :self do
      # end
    end
  end
end