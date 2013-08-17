require 'rails/generators'
require 'rails/generators/generated_attribute'
require 'schema_attributes'
require 'rails/generators/active_record/model/model_generator'
require 'active_record/base'

module Rails
  module Generators
    hide_namespace 'cocoon_model'


    class GeneratedAttribute
      alias _initialize initialize
      def initialize(name, type=nil, index_type=false, attr_options={})
        _initialize(name, type, index_type, attr_options)
        relationship index_type
      end

      def relationship rel=nil
        @relationship = rel.to_sym if %w(has_many has_one).include?(rel)
        @relationship ||= default_relationship
      end

      def default_relationship
        :has_many if reference?
      end

      def references?
        %w(references).include?(type)
      end

      def belongs_to?
        %w(belongs_to).include?(type)
      end

      def titleize
        name.titleize
      end

      def title_single
        singular_name.titleize
      end

      def title_plural
        plural_name.titleize
      end

      def singular_name
        return name unless has_many?
        name.singleize
      end

      def plural_name
        name.pluralize
      end

      def has_many?
        relationship == :has_many
      end

      def has_one?
        relationship == :has_one
      end
    end

    class CocoonModelGenerator < ActiveRecord::Generators::ModelGenerator
      # TODO: include both paths and remove the migration.rb model.rb and
      # TODO: madule.rb template files which will then be redundant
      #source_root "#{base_root}/active_record/model/templates"
      source_root File.expand_path("templates", File.dirname(__FILE__))

      def initialize(args, *options)
        @model_file = {}
        @serializer_file = {}
        @is_file = {}
        super args, *options
        attr = {}
        attributes.each
        #@schema_attributes = SchemaAttributes.parse(singular_name)
        @schema_attributes = SchemaAttributes.populate(file_path,
          Hash[attributes.map {|a| [a.name, a]}])
      end

      def self_association
        say_status :invoke, 'self_association', :white
        create_serializer singular_name
        Dir.glob("app/models/#{SchemaAttributes.path}*.rb") do |file|
          ref_name = file[/\w*(?=\.)/]
          ref = SchemaAttributes.parse(ref_name)
          if ref.belongs_to? singular_name
            assoc = ref.relationship singular_name
            inject_associate(assoc, ref_name, singular_name) &&
                inject_serialization(assoc, ref_name, singular_name)
            assoc_ref assoc, ref_name
            rref = ref[singular_name].dup
            rref.name, rref.type = ref_name, :references
            @schema_attributes.merge!({"#{ref_name}" => rref})
          end
        end
      end

      def parent_association
        say_status :invoke, 'parent_association', :white
        @schema_attributes.belongs_to.each do |name, att|
          assoc = att.relationship
          inject_relationship assoc, singular_name, name
          inject_associate assoc, singular_name, name
          inject_serialization assoc, singular_name, name if
              is_file? serializer_file name
        end
      end

      def inject_ar_audit_tracer
        Dir.glob('db/migrate/*.rb') do |file|
          contents = ''
          unless in_file? 't.authorstamps', file, contents
            if contents =~ /t.timestamps/
              gsub_file file, /t.timestamps/ do |match|
                match << "\n      t.authorstamps"
              end
            end
          end
        end
      end

      protected

      def create_serializer model
        template 'nested_serializer.rb', serializer_file(model)
      end

      def attributes_names
        [:id] + attributes.select { |attr| !attr.reference? }.map { |a| a.name.to_sym }
      end

      def inject_relationship(assoc, ref, model)
        insert_into_file model_file(ref), before: "belongs_to :#{model}" do
          assoc, ref = assoc_ref(assoc, ref).split(' :')
          "# #{model}:---#{assoc}--<:#{ref}\n  "
        end
      end

      def inject_associate(assoc, ref, model)
        inject_accepts_nested_attributes_for(assoc, ref, model_file(model))
        inject_file(assoc_ref(assoc, ref), model_file(model))
      end

      def inject_serialization(assoc, ref, model)
        create_serializer model unless is_file? serializer_file model
        inject_file( assoc_ref(assoc, ref), serializer_file(model))
      end

      def assoc_ref assoc, ref
        ref = ref.pluralize unless assoc =~ /one/
        #ref[/.*/] = ref.pluralize unless assoc =~ /one/
        "#{assoc} :#{ref}"
      end

      def model_file model
        @model_file[model.to_s.parameterize] ||= File.join('app/models', "#{SchemaAttributes.path}#{model}.rb")
      end

      def serializer_file model
        @serializer_file[model.to_s.parameterize] ||= File.join('app/serializers', "#{SchemaAttributes.path}#{model}_serializer.rb")
      end

      def is_file? file
        @is_file[file.to_s.parameterize] ||= File.exists? file
      end

      def in_file?(needle, file, contents='')
        return (contents[/.*/] = File.read(file)) =~ /#{needle}/ if is_file? file
        true
      end

      def inject_file(ref, model)
        unless in_file? ref, model
          klass = "#{SchemaAttributes.path}#{model[/\w*(?=\.)/]}".camelize
          inject_into_class model, klass, verbose: false do
            "  #{ref}\n"
            #"  #{ref}" + (only ? "\n" : ", dependent: :destroy\n")
          end
          true
        end
      end

      def inject_accepts_nested_attributes_for(assoc, ref, model)
        injection = "accepts_nested_attributes_for :#{(assoc[/one/] ? ref : ref.pluralize)}"
        injection << ", allow_destroy: true" unless assoc =~ /one/
        injection << ', update_only: true'
        inject_file injection, model
      end

    end
  end
end
