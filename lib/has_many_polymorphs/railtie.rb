# encoding: utf-8

class Railtie < ::Rails::Railtie
  initializer 'has_many_polymorphs.on_rails_init' do
    ActiveSupport.on_load :active_record do
      ActiveRecord::Base.send :include, HasManyPolymorphs::Base
    end
  end
end
