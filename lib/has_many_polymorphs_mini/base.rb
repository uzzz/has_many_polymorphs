module HasManyPolymorphsMini

  module Base
    extend ActiveSupport::Concern

    module ClassMethods
      def has_many_polymorphs(association_name, options = {})
        options.symbolize_keys!
        options.assert_valid_keys(
          :from,
          :as,
          :through,
          :order)

        raise ActiveRecord::Associations::PolymorphicError,
          ":from option must be an array" unless options[:from].is_a? Array
      end
    end
  end
end
