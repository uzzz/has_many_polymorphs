$LOAD_PATH << "." unless $LOAD_PATH.include?(".")

begin
  require 'rubygems'
  require 'bundler'

  if Gem::Version.new(Bundler::VERSION) <= Gem::Version.new("0.9.5")
    raise RuntimeError, "Your bundler version is too old." +
      "Run `gem install bundler` to upgrade."
  end

  # Set up load paths for all bundled gems
  Bundler.setup
rescue Bundler::GemNotFound
  raise RuntimeError, "Bundler couldn't find some gems." +
    "Did you run \`bundlee install\`?"
end

require File.expand_path('../../lib/has_many_polymorphs', __FILE__)
Bundler.require

# railtie doesn't work, don't know why, so just include here
ActiveRecord::Base.send(:include, HasManyPolymorphs::Base)

db_name = ENV['DB'] || 'sqlite3'
database_yml = File.expand_path('../database.yml', __FILE__)

if File.exists?(database_yml)
  active_record_configuration = YAML.load_file(database_yml)

  ActiveRecord::Base.configurations = active_record_configuration
  config = ActiveRecord::Base.configurations[db_name]

  begin
    ActiveRecord::Base.establish_connection(db_name)
    ActiveRecord::Base.connection
  rescue
    ActiveRecord::Base.establish_connection(config)
  end

  ActiveRecord::Base.logger = Logger.new(File.join(File.dirname(__FILE__), "debug.log"))
  ActiveRecord::Base.default_timezone = :utc

  ActiveRecord::Base.silence do
    ActiveRecord::Migration.verbose = false

    load(File.dirname(__FILE__) + '/schema.rb')
    load(File.dirname(__FILE__) + '/models.rb')
  end

else
  raise "Please create #{database_yml} first to configure your database. Take a look at: #{database_yml}.sample"
end

def clean_database!
  models = [SimpleModel]
  models.each do |model|
    ActiveRecord::Base.connection.execute "DELETE FROM #{model.table_name}"
  end
end

clean_database!
