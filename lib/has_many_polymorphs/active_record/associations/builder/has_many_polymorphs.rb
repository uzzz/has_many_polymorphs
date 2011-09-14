module ActiveRecord::Associations::Builder
  class HasManyPolymorphs < CollectionAssociation #:nodoc:
    self.macro = :has_many_polymorphs

    self.valid_options += [:dependent, :as, :through, :source, :source_type, :join_class_name, :from,
      :association_foreign_key, :polymorphic_key, :polymorphic_type_key, :join_extend, :parent_extend,
      :table_aliases, :rename_individual_collections]


    def build
      raise ActiveRecord::Associations::PolymorphicError,
        ":from option must be an array" unless options[:from].is_a? Array


      options[:as] ||= model.name.demodulize.underscore.to_sym
      options[:foreign_key] ||= "#{options[:as]}_id"
      options[:through] ||= build_join_table_symbol(name, (options[:as]._pluralize or model.table_name))
      options[:join_class_name] ||= options[:through]._classify

      options[:dependent] = :destroy unless options.has_key? :dependent

      options[:association_foreign_key] =
        options[:polymorphic_key] ||= "#{name._singularize}_id"
      options[:polymorphic_type_key] ||= "#{name._singularize}_type"

      options[:extend] = spiked_create_extension_module(name, Array(options[:extend]))
      options[:join_extend] = spiked_create_extension_module(name, Array(options[:join_extend]), "Join")
      options[:parent_extend] = spiked_create_extension_module(name, Array(options[:parent_extend]), "Parent")

      options[:table_aliases] ||= build_table_aliases([options[:through]] + options[:from])

      options[:select] ||= build_select(name, options[:table_aliases])

      reflection = super

      create_join_association(reflection)
      create_has_many_through_associations_for_children_to_parent(name, reflection)
      create_has_many_through_associations_for_parent_to_children(name, reflection)

      reflection
    end

    private

    def create_join_association(reflection)
      options = {
        :foreign_key => reflection.options[:foreign_key],
        :class_name  => reflection.klass.name,
        :dependent   => reflection.options[:dependent]
      }

      model.has_many(reflection.options[:through], options)
    end

    def create_has_many_through_associations_for_children_to_parent(association_id, reflection)
      child_pluralization_map(association_id, reflection).each do |plural, singular|
        parent = model

        if singular == reflection.options[:as]
          raise ActiveRecord::Associations::PolymorphicError,
            "You can't have a self-referential polymorphic has_many " +
            ":through without renaming the non-polymorphic foreign key in the join model."
        end

        plural._as_class.instance_eval do
          # the join table
          through = "#{reflection.options[:through]}#{'_as_child' if parent == self}".to_sym
          unless reflections[through]
            has_many(through,
              :as         => association_id._singularize,
              :class_name => reflection.klass.name
            )
          end

          # the association to the target's parents
          association = "#{reflection.options[:as]._pluralize}#{"_of_#{association_id}" if reflection.options[:rename_individual_collections]}".to_sym
          has_many(association,
            :through     => through,
            :class_name  => parent.name,
            :source      => reflection.options[:as],
            :foreign_key => reflection.options[:foreign_key],
            :extend      => reflection.options[:parent_extend],
            :conditions  => reflection.options[:parent_conditions],
            :order       => reflection.options[:parent_order],
            :offset      => reflection.options[:parent_offset],
            :limit       => reflection.options[:parent_limit],
            :group       => reflection.options[:parent_group]
          )
        end
      end
    end

    def create_has_many_through_associations_for_parent_to_children(association_id, reflection)
      child_pluralization_map(association_id, reflection).each do |plural, singular|
        current_association = child_association_map(association_id, reflection)[plural]
        source = singular

        # make push/delete accessible from the individual collections but still operate via the general collection
        extension_module = reflection.active_record.class_eval %[
          module #{model.name + current_association._classify + "PolymorphicChildAssociationExtension"}
            def push *args; proxy_association.owner.send(:#{association_id}).send(:push, *args); self; end
            alias :<< :push
            def delete *args; proxy_association.owner.send(:#{association_id}).send(:delete, *args); end
            self
          end
        ]

        model.has_many(
          current_association.to_sym,
          :through     => reflection.options[:through],
          :source      => association_id._singularize,
          :source_type => plural._as_class.base_class.name,
          :class_name  => plural._as_class.name, # make STI not conflate subtypes
          :extend      => (Array(extension_module)),
          :order       => reflection.options[:order]
         )
      end
    end

    def child_pluralization_map(association_id, reflection)
      Hash[*reflection.options[:from].map do |plural|
        [plural,  plural._singularize]
      end.flatten]
    end

    def child_association_map(association_id, reflection)
      Hash[*reflection.options[:from].map do |plural|
        [plural, "#{association_id._singularize.to_s + "_" if reflection.options[:rename_individual_collections]}#{plural}".to_sym]
      end.flatten]
    end

    def spiked_create_extension_module(association_id, extensions, identifier = nil)
      module_extensions = extensions.select{|e| e.is_a? Module}
      proc_extensions = extensions.select{|e| e.is_a? Proc }

      # support namespaced anonymous blocks as well as multiple procs
      proc_extensions.each_with_index do |proc_extension, index|
        module_name = "#{self.to_s}#{association_id.to_s.classify}Polymorphic#{identifier}AssociationExtension#{index}"
        the_module = self.class_eval "module #{module_name}; self; end" # XXX hrm
        the_module.class_eval &proc_extension
        module_extensions << the_module
      end

      module_extensions
    end

    def build_table_aliases(from)
      # for the targets
      {}.tap do |aliases|
        from.map(&:to_s).sort.map(&:to_sym).each_with_index do |plural, t_index|
          begin
            table = plural.to_s.classify.constantize.table_name
          rescue NameError => e
            raise ActiveRecord::Associations::PolymorphicError,
              "Could not find a valid class for #{plural.inspect} " +
              "(tried #{plural.to_s.classify.constantize}). If it's namespaced, be sure to specify it " +
              "as :\"module/#{plural}\" instead."
          end
          begin
            plural.to_s.classify.constantize.columns.map(&:name).each_with_index do |field, f_index|
              aliases["#{table}.#{field}"] = "t#{t_index}_r#{f_index}"
            end
          rescue ActiveRecord::StatementInvalid => e
            # _logger_warn "Looks like your table doesn't exist for #{plural.to_s._classify}.\\nError #{e}\\nSkipping..."
          end
        end
      end
    end

    def build_select(association_id, aliases)
      # <tt>instantiate</tt> has to know which reflection the results are coming from
      (["\'#{@model.name}\' AS polymorphic_parent_class",
         "\'#{association_id}\' AS polymorphic_association_id"] +
      aliases.map do |table, _alias|
        "#{table} AS #{_alias}"
      end.sort).join(", ")
    end

    def build_join_table_symbol(association_id, name)
      [name.to_s, association_id.to_s].sort.join("_").to_sym
    end

  end
end
