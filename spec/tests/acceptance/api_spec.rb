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
  QUERY_CODE = 'afdfa'

  before do
    VcrHelper.configure_vcr_for_amadeus
    # DatabaseHelper.wipe_database
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Appraise project folder route' do
    it 'should be able to appraise a project folder' do
      get "/api/trips/#{QUERY_CODE}"

      _(last_response.status).must_equal 404
      # appraisal = JSON.parse last_response.body
      puts "hahaahaha --- #{last_response.body}"
    end
  end
end
