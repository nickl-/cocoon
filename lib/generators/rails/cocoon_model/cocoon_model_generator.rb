require 'rails/generators/active_record/model/model_generator'

module Rails
  module Generators
    hide_namespace 'cocoon_model'
    class CocoonModelGenerator < ActiveRecord::Generators::ModelGenerator
      source_root "#{base_root}/active_record/model/templates"

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

      protected

      def inject_associate(ref, model)
        if File.exist?(model = File.join('app/models', "#{model}.rb"))
          unless File.read(model) =~ /has_many :#{ref}/
            inject_accepts_nested_attributes_for ref, model
            inject_has_many ref, model
          end
          inject_attr_accessible ref, model
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
