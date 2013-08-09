require 'rails/generators/active_record/model/model_generator'

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
        @relationship = rel if %w(has_many has_one).include?(rel)
        @relationship ||= default_relationship
      end

      def has_many?
        %w(has_many).include?(relationship)
      end

      def has_one?
        %w(has_one).include?(relationship)
      end

      def default_relationship
        'has_many' if reference?
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
      end

      def self_association
        say_status :invoke, 'self_association', :white
        create_serializer singular_name
        Dir.glob('app/models/*') do |file|
          assoc = ''
          if in_file? "belongs_to :#{singular_name}", file, assoc
            ref = file[/\w*(?=\.)/]
            assoc = assoc[/# #{singular_name}:-*(\w*)-*.:#{ref}/, 1]
            inject_associate(assoc, ref, singular_name) &&
              inject_serialization(assoc, ref, singular_name)
          end
        end
      end

      def parent_association
        say_status :invoke, 'parent_association', :white
        attributes.each do |att|
          if att.reference?
            inject_relationship att.relationship, singular_name, att.name
            inject_associate att.relationship, singular_name, att.name
            inject_serialization att.relationship, singular_name, att.name if
                is_file? serializer_file att.name
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
        assoc, ref = assoc_ref(assoc, ref).split(' :')
        inject_file "# #{model}:---#{assoc}--<:#{ref}", model_file(ref.singularize), true
      end

      def inject_associate(assoc, ref, model)
        inject_accepts_nested_attributes_for( (assoc[/one/] ? ref : ref.pluralize), model_file(model))
        inject_file(assoc_ref(assoc, ref), model_file(model))
        inject_attr_accessible(ref, model_file(model))
      end

      def inject_serialization(assoc, ref, model)
        create_serializer model unless is_file? serializer_file model
        inject_file( assoc_ref(assoc, ref), serializer_file(model), true)
      end

      def assoc_ref assoc, ref
        ref[/.*/] = ref.pluralize unless assoc =~ /one/
        "#{assoc} :#{ref}"
      end

      def model_file model
        @model_file[model.parameterize] ||= File.join('app/models', "#{model}.rb")
      end

      def serializer_file model
        @serializer_file[model.parameterize] ||= File.join('app/serializers', "#{model}_serializer.rb")
      end

      def is_file? file
        @is_file[file.parameterize] ||= File.exists? file
      end

      def in_file?(needle, file, contents='')
        return (contents[/.*/] = File.read(file)) =~ /#{needle}/ if is_file? file
        true
      end

      def inject_file(ref, model, only=false)
        unless in_file? ref, model
          inject_into_class model, model[/\w*(?=\.)/].camelize do
            "  #{ref}" + (only ? "\n" : ", dependent: :destroy\n")
          end
          true
        end
      end

      def inject_attr_accessible(ref, model)
        gsub_file "#{model}", /attr_accessible .*/ do  |m|
          m << ", :#{ref}_attributes" unless m.to_s =~ /#{ref}_attributes/
        end
        true
      end

      def inject_accepts_nested_attributes_for(ref, model)
        inject_file "accepts_nested_attributes_for :#{ref}, reject_if: :all_blank, allow_destroy: true",
            model, true
      end

    end
  end
end
