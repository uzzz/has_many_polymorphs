module ActiveRecord #:nodoc
  module Associations #:nodoc

    class PolymorphicError < ActiveRecordError #:nodoc
    end

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
        Association::PolymorphicAssociation
      end
    end

    class Association
      def association_scope
        if klass
          @association_scope ||= if self.is_a? ActiveRecord::Associations::PolymorphicAssociation
                                   PolymorphicAssociationScope.new(self).scope
                                 else
                                   AssociationScope.new(self).scope
                                 end
        end
      end
    end

    # The association class for a <tt>has_many_polymorphs</tt> association.
    class PolymorphicAssociation < HasManyThroughAssociation

     #  # Push a record onto the association. Triggers a database load for a uniqueness check only if <tt>:skip_duplicates</tt> is <tt>true</tt>. Return value is undefined.
      def <<(*records)
        return if records.empty?

        if @reflection.options[:skip_duplicates]
          _logger_debug "Loading instances for polymorphic duplicate push check; use :skip_duplicates => false and perhaps a database constraint to avoid this possible performance issue"
          load_target
        end

        @reflection.klass.transaction do
          flatten_deeper(records).each do |record|
            if @owner.new_record? or not record.respond_to?(:new_record?) or record.new_record?
              raise PolymorphicError, "You can't associate unsaved records."
            end
            next if @reflection.options[:skip_duplicates] and @target.include? record
            @owner.association(@reflection.through_reflection.name).target << @reflection.klass.create!(construct_join_attributes(record))
            @target << record if loaded?
          end
        end

        self
      end

      alias :push :<<
      alias :concat :<<

     #  # Runs a <tt>find</tt> against the association contents, returning the matched records. All regular <tt>find</tt> options except <tt>:include</tt> are supported.
     #  def find(*args)
     #    opts = args._extract_options!
     #    opts.delete :include
     #    super(*(args + [opts]))
     #  end

     # # Deletes a record from the association. Return value is undefined.
      def delete(*records)
        records = flatten_deeper(records)
        records.reject! {|record| @target.delete(record) if record.new_record?}
        return if records.empty?

        @reflection.klass.transaction do
          records.each do |record|
            joins = @reflection.through_reflection.name
            @owner.send(joins).delete(@owner.send(joins).select do |join|
              join.send(@reflection.options[:polymorphic_key]) == record.id and
              join.send(@reflection.options[:polymorphic_type_key]) == "#{record.class.base_class}"
            end)
            @target.delete(record)
          end
        end
      end

      # Clears all records from the association. Returns an empty array.
      def delete_all
        load_target
        return if @target.empty?

        @owner.send(@reflection.through_reflection.name).clear
        @target.clear

        []
      end

     #  def target_reflection_has_associated_record?
     #    false
     #  end

      protected

      # construct attributes for join for a particular record
      def construct_join_attributes(record) #:nodoc:
        {
          @reflection.options[:polymorphic_key]      => record.id,
          @reflection.options[:polymorphic_type_key] => "#{record.class.base_class}",
          @reflection.options[:foreign_key]          => @owner.id
        }.merge(
          @reflection.options[:foreign_type_key] ?
            { @reflection.options[:foreign_type_key] => "#{@owner.class.base_class}" } :
            {}
        ) # for double-sided relationships
      end

      def build(attrs = nil) #:nodoc:
        raise PolymorphicMethodNotSupportedError, "You can't associate new records."
      end

      if RUBY_VERSION < '1.9.2'
        # Array#flatten has problems with recursive arrays before Ruby 1.9.2.
        # Going one level deeper solves the majority of the problems.
        def flatten_deeper(array)
          array.collect { |element| (element.respond_to?(:flatten) && !element.is_a?(Hash)) ? element.flatten : element }.flatten
        end
      else
        def flatten_deeper(array)
          array.flatten
        end
      end

    end
  end
end
