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
      def permissible_attributes
        SchemaAttributes.parse(singular_name).permissible
      end
    end

  end
end
