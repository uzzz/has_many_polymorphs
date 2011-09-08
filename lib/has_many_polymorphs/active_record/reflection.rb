module ActiveRecord #:nodoc:
  module Reflection #:nodoc:

    module ClassMethods #:nodoc:
      # Update the default reflection switch so that <tt>:has_many_polymorphs</tt> types get instantiated.
      # It's not a composed method so we have to override the whole thing.
      def create_reflection(macro, name, options, active_record)
        case macro
          when :has_many, :belongs_to, :has_one, :has_and_belongs_to_many
            klass = options[:through] ? ThroughReflection : AssociationReflection
            reflection = klass.new(macro, name, options, active_record)
          when :composed_of
            reflection = AggregateReflection.new(macro, name, options, active_record)
          when :has_many_polymorphs
            reflection = PolymorphicReflection.new(macro, name, options, active_record)
        end

        self.reflections = self.reflections.merge(name => reflection)
        reflection
      end
    end

    class AssociationReflection < MacroReflection #:nodoc:
      def association_class
        case macro
          when :belongs_to
            if options[:polymorphic]
              Associations::BelongsToPolymorphicAssociation
            else
              Associations::BelongsToAssociation
            end
          when :has_and_belongs_to_many
            Associations::HasAndBelongsToManyAssociation
          when :has_many
            if options[:through]
              Associations::HasManyThroughAssociation
            else
              Associations::HasManyAssociation
            end
          when :has_one
            if options[:through]
              Associations::HasOneThroughAssociation
            else
              Associations::HasOneAssociation
            end
          when :has_many_polymorphs
            Associations::PolymorphicAssociation
        end
      end
    end

    class PolymorphicError < ActiveRecordError #:nodoc:
    end

=begin rdoc

The reflection built by the <tt>has_many_polymorphs</tt> method.

Inherits from ActiveRecord::Reflection::AssociationReflection.

=end

    class PolymorphicReflection < ThroughReflection
      def initialize(macro, name, options, active_record)
        super
        @collection = true
      end

      # Stub out the validity check. Has_many_polymorphs checks validity on macro creation, not on reflection.
      def check_validity!
        # nothing
      end

      # Set the classname of the target. Uses the join class name.
      def class_name
        # normally is the classname of the association target
        @class_name ||= options[:join_class_name]
      end

    end

  end
end
