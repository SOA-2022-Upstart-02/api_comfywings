# frozen_string_literal: true

require 'rake/testtask'
require_relative 'require_app'

task :default do
  puts `rake -T`
end

desc 'Run unit and integration tests'
Rake::TestTask.new(:spec_all) do |t|
  t.pattern = 'spec/tests/**/*_spec.rb'
  t.warning = false
end

desc 'Run acceptance tests'
Rake::TestTask.new(:spec_acc) do |t|
  t.pattern = 'spec/tests/acceptance/*_spec.rb'
  t.warning = false
end

namespace :run do
  desc 'Starts API in dev mode (rerun)'
  task :dev do
    sh 'bundle exec puma -p 9090'
  end

  desc 'Starts API in test mode'
  task :test do
    sh 'RACK_ENV=test bundle exec puma -p 9090'
  end
end

desc 'Keep rerunning tests upon changes'
task :respec do
  sh "rerun -c 'rake spec' --ignore 'coverage/*'"
end

desc 'Keep restarting web app in dev mode upon changes'
task :rerun do
  sh "rerun -c --ignore 'coverage/*' --ignore 'repostore/*' -- bundle exec puma -p 9090"
end

namespace :db do
  task :config do
    require 'sequel'
    require_relative 'config/environment' # load config info
    require_relative 'spec/helpers/database_helper'

    def app = ComfyWings::App
  end

  desc 'Run migrations'
  task :migrate => :config do
    Sequel.extension :migration
    puts "Migrating #{app.environment} database to latest"
    Sequel::Migrator.run(app.DB, 'db/migrations')
  end

  task :edit => :config do
    Sequel.extension :migration
    puts "123"
    Sequel::Migrator.run(app.DB, 'db/edit')
  end

  desc 'Wipe records from all tables'
  task :wipe => :config do
    if app.environment == :production
      puts 'Do not damage production database!'
      return
    end

    require_app('infrastructure')
    DatabaseHelper.wipe_database
  end

  desc 'Delete dev or test database file (set correct RACK_ENV)'
  task :drop => :config do
    if app.environment == :production
      puts 'Do not damage production database!'
      return
    end

    FileUtils.rm(ComfyWings::App.config.DB_FILENAME)
    puts "Deleted #{ComfyWings::App.config.DB_FILENAME}"
  end
end

desc 'Run application console'
task :console do
  sh 'pry -r ./load_all'
end

namespace :vcr do
  desc 'Delete cassette fixtures'
  task :wipe do
    sh 'rm spec/fixtures/cassettes/*.yml' do |ok, _|
      puts(ok ? 'Cassettes deleted successfully.' : 'Cassettes not found.')
    end
  end
end

namespace :quality do
  only_app = 'config/ app/'

  desc 'Run all static-analysis quality checks'
  task all: %i[rubocop reek flog]

  desc 'Only check for unidiomatic code'
  task :rubocop do
    sh 'rubocop'
  end

  desc 'Check for unidiomatic code and safely autocorrect violations.'
  task :rubocop_autocorrect do
    sh 'rubocop --autocorrect'
  end

  desc 'Only check for code smells'
  task :reek do
    sh 'reek'
  end

  desc 'Only analyze code complexity'
  task :flog do
    sh "flog -m #{only_app}"
  end
end

desc 'Update fixtures and wipe VCR cassettes'
task :update_fixtures => 'vcr:wipe' do
  sh 'ruby spec/fixtures/flight_info.rb'
end

desc 'Generate 64-bit session key for Rack::Session'
task :new_session_secret do
  require 'base64'
  require 'securerandom'
  secret = SecureRandom.random_bytes(64).then { Base64.urlsafe_encode64(_1) }
  puts "SESSION_SECRET: #{secret}"
end

namespace :cache do
  task :config do
    require_relative 'config/environment' # load config info
    require_relative 'app/infrastructure/cache/*'
    @api = ComfyWings::App
  end

  desc 'Directory listing of local dev cache'
  namespace :list do
    task :dev do
      puts 'Lists development cache'
      list = `ls _cache/rack/meta`
      puts 'No local cache found' if list.empty?
      puts list
    end

    desc 'Lists production cache'
    task :production => :config do
      puts 'Finding production cache'
      keys = ComfyWings::Cache::Client.new(@api.config).keys
      puts 'No keys found' if keys.none?
      keys.each { |key| puts "Key: #{key}" }
    end
  end

  namespace :wipe do
    desc 'Delete development cache'
    task :dev do
      puts 'Deleting development cache'
      sh 'rm -rf _cache/*'
    end

    desc 'Delete production cache'
    task :production => :config do
      print 'Are you sure you wish to wipe the production cache? (y/n) '
      if $stdin.gets.chomp.downcase == 'y'
        puts 'Deleting production cache'
        wiped = ComfyWings::Cache::Client.new(@api.config).wipe
        wiped.each_key { |key| puts "Wiped: #{key}" }
      end
    end
  end
end

namespace :queues do
  task :config do
    require 'aws-sdk-sqs'
    require_relative 'config/environment' # load config info
    @api = ComfyWings::App
    @sqs = Aws::SQS::Client.new(
      access_key_id: @api.config.AWS_ACCESS_KEY_ID,
      secret_access_key: @api.config.AWS_SECRET_ACCESS_KEY,
      region: @api.config.AWS_REGION
    )
    @q_name = @api.config.UPDATE_QUEUE
    @q_url = @sqs.get_queue_url(queue_name: @q_name).queue_url

    puts "Environment: #{@api.environment}"
  end

  desc 'Create SQS queue for worker'
  task :create => :config do
    @sqs.create_queue(queue_name: @q_name)

    puts 'Queue created:'
    puts "  Name: #{@q_name}"
    puts "  Region: #{@api.config.AWS_REGION}"
    puts "  URL: #{@q_url}"
  rescue StandardError => e
    puts "Error creating queue: #{e}"
  end

  desc 'Report status of queue for worker'
  task :status => :config do
    puts 'Queue info:'
    puts "  Name: #{@q_name}"
    puts "  Region: #{@api.config.AWS_REGION}"
    puts "  URL: #{@q_url}"
  rescue StandardError => e
    puts "Error finding queue: #{e}"
  end

  desc 'Purge messages in SQS queue for worker'
  task :purge => :config do
    @sqs.purge_queue(queue_url: @q_url)
    puts "Queue #{@q_name} purged"
  rescue StandardError => e
    puts "Error purging queue: #{e}"
  end
end

namespace :worker do
  namespace :run do
    desc 'Run the background cloning worker in development mode'
    task :dev => :config do
      sh 'RACK_ENV=development bundle exec shoryuken -r ./workers/git_clone_worker.rb -C ./workers/shoryuken_dev.yml'
    end

    desc 'Run the background cloning worker in testing mode'
    task :test => :config do
      sh 'RACK_ENV=test bundle exec shoryuken -r ./workers/git_clone_worker.rb -C ./workers/shoryuken_test.yml'
    end

    desc 'Run the background cloning worker in production mode'
    task :production => :config do
      sh 'RACK_ENV=production bundle exec shoryuken -r ./workers/git_clone_worker.rb -C ./workers/shoryuken.yml'
    end
  end
end