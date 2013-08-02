require 'rails/generators/rails/scaffold/scaffold_generator'

module Rails
  module Generators
    class CocoonScaffoldGenerator < Rails::Generators::ScaffoldGenerator
      hook_for :stylesheet_engine, as: :cocoon do |stylesheet_engine|
        invoke stylesheet_engine, [controller_name] if options[:stylesheets] && behavior == :invoke
      end
    end
  end
end
