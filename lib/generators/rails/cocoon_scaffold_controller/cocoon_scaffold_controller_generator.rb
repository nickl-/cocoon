module Rails
  module Generators
    require 'rails/generators/rails/scaffold_controller/scaffold_controller_generator'
    require 'schema_attributes'

    class CocoonScaffoldControllerGenerator < Rails::Generators::ScaffoldControllerGenerator
      source_root File.expand_path("../templates", __FILE__)
      remove_hook_for :template_engine
      hook_for :template_engine, as: :cocoon

      def appliaction_responder
        copy_file 'application_responder.rb', 'lib/application_responder.rb'
      end

      protected
      def strong_parameters
        say_status :insert, 'injecting strong parameters', :blue
        recurse_references singular_name, '  '
      end

      def recurse_references(model, indent)
        ret = ''
        SchemaAttributes.parse(model).references.each do |name, att|
          ret << ",\n      #{indent}#{att.name}_attributes: ["
          ret << ":_destroy, :id, "
          ret << SchemaAttributes.parse(name).permissible
          ret << recurse_references(name, indent+indent)
          ret << ']'
        end
        ret
      end

      def permissible_attributes
        #":#{SchemaAttributes.parse('person').belongs_to.values.map(&:name)*', :'}, " <<
          SchemaAttributes.parse(singular_name).permissible
      end

    end
  end
end
