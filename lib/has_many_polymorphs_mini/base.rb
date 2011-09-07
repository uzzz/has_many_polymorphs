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

        options[:as] ||= self.name.demodulize.underscore.to_sym
        options[:foreign_key] = "#{options[:as]}_id"
        options[:join_class_name] = options[:through].to_s.classify

        reflection = create_reflection(:has_many_polymorphs, association_name, options, self).tap do |reflection|
          create_join_association(association_name, reflection)
          create_has_many_through_associations_for_children_to_parent(association_name, reflection)
          create_has_many_through_associations_for_parent_to_children(association_name, reflection)
        end

        collection_reader_method(reflection, ActiveRecord::Associations::PolymorphicAssociation)
      end

      def create_join_association(association_id, reflection)
        options = {
          :foreign_key => reflection.options[:foreign_key],
          :class_name => reflection.klass.name,
        }

        has_many(reflection.options[:through], options)
      end

      def create_has_many_through_associations_for_children_to_parent(association_id, reflection)
        parent = self

        child_pluralization_map(association_id, reflection).each do |plural, singular|
          if singular == reflection.options[:as]
            raise PolymorphicError, "You can't have a self-referential polymorphic has_many " +
              ":through without renaming the non-polymorphic foreign key in the join model."
          end

          plural.to_s.classify.constantize.instance_eval do
            # the join table
            through = "#{reflection.options[:through]}#{'_as_child' if parent == self}".to_sym
            unless reflections[through]
              has_many(through,
                :as         => association_id.to_s.singularize,
                :class_name => reflection.klass.name
              )
            end

            # the association to the target's parents
            association = reflection.options[:as].to_s.pluralize.to_sym
            has_many(association,
              :through    => through,
              :class_name => parent.name,
              :source     => reflection.options[:as]
            )
          end
        end
      end

      def create_has_many_through_associations_for_parent_to_children(association_id, reflection)
        child_pluralization_map(association_id, reflection).each do |plural, singular|
          current_association = child_association_map(association_id, reflection)[plural]
          source = singular

          # make push/delete accessible from the individual collections but still operate via the general collection
          extension_module = self.class_eval %[
            module #{self.name + current_association.to_s.classify + "PolymorphicChildAssociationExtension"}
              def push *args; proxy_owner.send(:#{association_id}).send(:push, *args); self; end
              alias :<< :push
              def delete *args; proxy_owner.send(:#{association_id}).send(:delete, *args); end
              def clear; proxy_owner.send(:#{association_id}).send(:clear, #{singular.to_s.classify}); end
              self
            end
          ]

          has_many(
            current_association.to_sym,
            :through     => reflection.options[:through],
            :source      => association_id.to_s.singularize,
            :source_type => plural.to_s.classify.constantize.base_class.name,
            :class_name  => plural.to_s.classify.constantize.name, # make STI not conflate subtypes
            :extend => (Array(extension_module))#,
            # :limit => reflection.options[:limit],
            # :order => devolve(association_id, reflection, reflection.options[:order], plural._as_class),
            # :conditions => devolve(association_id, reflection, reflection.options[:conditions], plural._as_class),
            # :group => devolve(association_id, reflection, reflection.options[:group], plural._as_class)
           )
        end
      end

      def child_pluralization_map(association_id, reflection)
        Hash[*reflection.options[:from].map do |plural|
          [plural,  plural.to_s.singularize.to_sym]
        end.flatten]
      end

      def child_association_map(association_id, reflection)
        Hash[*reflection.options[:from].map do |plural|
          [plural, "#{association_id._singularize.to_s + "_" if reflection.options[:rename_individual_collections]}#{plural}".to_sym]
        end.flatten]
      end

    end
  end
end
