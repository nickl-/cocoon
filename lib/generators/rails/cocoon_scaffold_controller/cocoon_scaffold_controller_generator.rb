module Rails
  module Generators
    hide_namespace 'cocoon_scaffold_controller'

    begin
      require 'generators/rails/inherited_resources_controller_generator'
      DESIGNATED_SUPER = Rails::Generators::InheritedResourcesControllerGenerator
    rescue LoadError
      require 'rails/generators/rails/scaffold_controller/scaffold_controller_generator'
      DESIGNATED_SUPER = Rails::Generators::ScaffoldControllerGenerator
    end

    class CocoonScaffoldControllerGenerator < DESIGNATED_SUPER
      if source_root.nil?
        source_root "#{base_root}/rails/scaffold_controller/templates"
      end
      remove_hook_for :template_engine
      hook_for :template_engine, as: :cocoon
      def present_delegate
        say_status :delegated, DESIGNATED_SUPER.to_s[/(\w*)$/,1].titleize, :blue
      end
    end

  end
end
