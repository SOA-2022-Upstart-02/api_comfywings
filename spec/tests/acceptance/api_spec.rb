# frozen_string_literal: true

require_relative '../../helpers/spec_helper'
require_relative '../../helpers/vcr_helper'
require_relative '../../helpers/database_helper'
require 'rack/test'

def app
  ComfyWings::App
end

describe 'Test API routes' do
  include Rack::Test::Methods

  VcrHelper.setup_vcr
  QUERY_CODE = 'temp_for_test'

  before do
    VcrHelper.configure_vcr_for_amadeus
    # DatabaseHelper.wipe_database
  end

  after do
    VcrHelper.eject_vcr
  end

  describe '' do
    it '' do
      get "/api/trips/#{QUERY_CODE}"
      _(last_response.status).must_equal 200

      response = JSON.parse(last_response.body)
    end
  end

  describe '' do
    it '' do
      post '/api/trip_query'
      _(last_response.status).must_equal 200

      response = JSON.parse(last_response.body)
    end
  end
end
