module ActiveRecord
  module Associations
    class PolymorphicAssociationScope < AssociationScope
      def add_constraints(scope)
        scope.joins(construct_joins)
      end

      private

      def construct_from #:nodoc:
        # build the FROM part of the query, in this case, the polymorphic join table
        @association.reflection.klass.quoted_table_name
      end

      def construct_owner #:nodoc:
        # the table name for the owner object's class
        owner.class.quoted_table_name
      end

      def construct_owner_key #:nodoc:
        # the primary key field for the owner object
        owner.class.primary_key
      end

      def construct_joins(custom_joins = nil) #:nodoc:
        # build the string of default joins
        "JOIN #{construct_owner} AS polymorphic_parent ON #{construct_from}.#{options[:foreign_key]} = polymorphic_parent.#{construct_owner_key} " +
        options[:from].map do |plural|
          klass = plural.to_s.classify.constantize
          "LEFT JOIN #{klass.quoted_table_name} " +
          "ON #{construct_from}.#{options[:polymorphic_key]} = #{klass.quoted_table_name}.#{klass.primary_key} " +
          "AND #{construct_from}.#{options[:polymorphic_type_key]} = #{@association.reflection.klass.quote_value(klass.base_class.name)}"
        end.uniq.join(" ")# + " #{custom_joins}"
      end
    end
  end
end
