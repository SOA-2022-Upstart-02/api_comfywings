# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'openstruct_with_links'
require_relative 'currency_representer'

module ComfyWings
  module Representer
    # Represents list of currencies
    class CurrenciesList < Roar::Decorator
      include Roar::JSON

      collection :trips, extend: Representer::Currency, lass: Representer::OpenStructWithLinks
    end
  end
end
