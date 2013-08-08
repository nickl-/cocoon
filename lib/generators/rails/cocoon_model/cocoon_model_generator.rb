require 'rails/generators/active_record/model/model_generator'

module Rails
  module Generators
    hide_namespace 'cocoon_model'
    class CocoonModelGenerator < ActiveRecord::Generators::ModelGenerator
      # TODO: include both paths and remove the migration.rb model.rb and
      # TODO: madule.rb template files which will then be redundant
      #source_root "#{base_root}/active_record/model/templates"
      source_root File.expand_path("templates", File.dirname(__FILE__))

      def self_association
        say_status :invoke, 'self_association', :white
        Dir.glob('app/models/*') { |file|
          File.read(file).lines { |line|
            if line =~ /belongs_to :#{name.underscore}/
              inject_associate file[/\w*(?=\.)/].tableize, name.underscore
            end
          }
        }
      end

      def parent_association
        say_status :invoke, 'parent_association', :white
        attributes.each do |att|
          if %w(belongs_to references).include? att.type.to_s
            inject_associate name.tableize, att.name.underscore
          end
        end
      end

      def create_serializer
        template 'nested_serializer.rb', File.join('app/serializers', "#{name.underscore}_serializer.rb")
      end

      def self_serialization
        say_status :invoke, 'self_serialization', :white
        Dir.glob('app/models/*') { |file|
          File.read(file).lines { |line|
            if line =~ /belongs_to :#{name.underscore}/
              unless File.exist?(model = File.join('app/serializers', "#{name.underscore}_serializer.rb"))
                create_serializer
              end
              inject_serialization file[/\w*(?=\.)/].tableize, name.underscore
            end
          }
        }
      end

      def parent_serialization
        say_status :invoke, 'parent_serialization', :white
        attributes.each do |att|
          if %w(belongs_to references).include? att.type.to_s
            inject_serialization name.tableize, att.name.underscore
          end
        end
      end

      protected

      def attributes_names
        [:id] + attributes.select { |attr| !attr.reference? }.map { |a| a.name.to_sym }
      end

      def inject_associate(ref, model)
        if File.exist?(model = File.join('app/models', "#{model}.rb"))
          unless File.read(model) =~ /has_many :#{ref}/
            inject_accepts_nested_attributes_for ref, model
            inject_has_many ref, model
          end
          inject_attr_accessible ref, model
        end
      end

      def inject_serialization(ref, model)
        if File.exist?(model = File.join('app/serializers', "#{model}_serializer.rb"))
          unless File.read(model) =~ /has_many :#{ref}/
            inject_has_many ref, model, true
          else
            say_status :identical, model, :blue
          end
        end
      end

      def inject_has_many(ref, model, only=false)
        inject_into_class model, model[/\w*(?=\.)/].camelize do
          "  has_many :#{ref}" + (only ? "\n" : ", dependent: :destroy\n")
        end
      end

      def inject_attr_accessible(ref, model)
        gsub_file "#{model}", /attr_accessible .*/ do  |m|
          m << ", :#{ref}_attributes" unless m.to_s =~ /#{ref}_attributes/
        end
      end

      def inject_has_many(ref, model)
        inject_into_file model, "  has_many :#{ref}, dependent: :destroy\n", :after => " < ActiveRecord::Base\n"
      end

      def inject_accepts_nested_attributes_for(ref, model)
        snippet = "  accepts_nested_attributes_for :#{ref}, reject_if: :all_blank, allow_destroy: true\n"
        inject_into_file model, snippet, :after => " < ActiveRecord::Base\n"
      end

    end
  end
end
