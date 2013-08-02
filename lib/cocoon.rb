require 'cocoon/view_helpers'

module Cocoon
  class Engine < ::Rails::Engine

    config.before_initialize do
      if config.action_view.javascript_expansions
        config.action_view.javascript_expansions[:cocoon] = %w(cocoon)
      end
    end

    # configure our plugin on boot
    initializer "cocoon.initialize" do |app|
      ActionView::Base.send :include, Cocoon::ViewHelpers
    end

  end

  class Railtie < ::Rails::Engine
    if config.respond_to?(:app_generators)
      config.app_generators.scaffold_controller = :cocoon_scaffold_controller
      config.app_generators.scaffold = :cocoon_scaffold
      config.app_generators.orm = :cocoon_model
    else
      config.generators.scaffold_controller = :cocoon_scaffold_controller
      config.generators.scaffold = :cocoon_scaffold
      config.generators.orm = :cocoon_model
    end
  end

end
