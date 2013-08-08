module Rails
  module Generators
    require 'rails/generators/rails/scaffold_controller/scaffold_controller_generator'

    class CocoonScaffoldControllerGenerator < Rails::Generators::ScaffoldControllerGenerator
      source_root File.expand_path("../templates", __FILE__)
      remove_hook_for :template_engine
      hook_for :template_engine, as: :cocoon

      def appliaction_responder
        copy_file 'application_responder.rb', 'lib/application_responder.rb'
      end
    end

  end
end
