# encoding: utf-8
require 'has_many_polymorphs_mini'
require 'rails'

class Railtie < ::Rails::Railtie
  initializer "has_many_polymorphs_mini.on_rails_init" do
    ActiveSupport.on_load :active_record do
      ActiveRecord::Base.send :include, HasManyPolymorphsMini::Base
    end
  end
end
