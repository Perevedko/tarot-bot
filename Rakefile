require 'rubygems'
require 'bundler/setup'

require 'pg'
require 'active_record'
require 'yaml'

namespace :db do

  desc 'Migrate the database'
  task :migrate do
    connection_details = YAML::load(File.open('config/database.yml'))
    ActiveRecord::Base.establish_connection(connection_details)
    ActiveRecord::Migrator.migrate('db/migrate/')
  end

  desc 'Create the database'
  task :create do
    connection_details = YAML::load(File.open('config/database.yml'))
    admin_connection = connection_details.merge({'database'=> 'postgres',
                                                'schema_search_path'=> 'public'})
    ActiveRecord::Base.establish_connection(admin_connection)
    ActiveRecord::Base.connection.create_database(connection_details.fetch('database'))
  end

  desc 'Drop the database'
  task :drop do
    connection_details = YAML::load(File.open('config/database.yml'))
    admin_connection = connection_details.merge({'database'=> 'postgres',
                                                'schema_search_path'=> 'public'})
    ActiveRecord::Base.establish_connection(admin_connection)
    ActiveRecord::Base.connection.drop_database(connection_details.fetch('database'))
  end
end

task :console do
  require 'pry'
  require 'telegram/bot'
  require_relative 'lib/app_configurator'
  config = AppConfigurator.new
  config.configure
  dir = File.dirname(__FILE__)
  Dir["#{dir}/*.rb",
      "#{dir}/models/*.rb",
      "#{dir}/lib/*.rb"
  ].each(&method(:require))
  Pry.start
end

task :c => :console
