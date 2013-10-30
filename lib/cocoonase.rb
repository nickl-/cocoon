require 'cocoonase/view_helpers'
module Cocoonase
  extend ActiveSupport::Autoload
  #autoload :Inputs
  #
  #eager_autoload do
  #  autoload :Inputs
  #end

  #def self.eager_load!
  #  super
  #  Cocoonase::Inputs.eager_load!
  #end

  class Engine < ::Rails::Engine
    #config.eager_load_paths += Dir["#{File.expand_path('../', __FILE__)}/lib/cocoonase/inputs"]
    #    config.autoload_paths += Dir["#{File.expand_path('../', __FILE__)}/lib/inputs/**/"]
    #
    config.before_initialize do
      if config.action_view.javascript_expansions
        #config.action_view.javascript_expansions[:masonry_docs] = %w(masonry-docs.min)
        config.action_view.javascript_expansions[:cocoonase] = %w(cocoonase)
      end
      #if config.action_view.stylesheet_expansions
      #  config.action_view.stylesheet_expansions = %w(cocoonase)
      #end
    end

    # configure our plugin on boot
    initializer "cocoonase.initialize" do |app|
      #eager_load!
      ActionView::Base.send :include, Cocoonase::ViewHelpers
    end

  end
  #
  #class Railtie < ::Rails::Engine
  #  if config.respond_to?(:app_generators)
  #    config.app_generators.scaffold_controller = :cocoon_scaffold_controller
  #    config.app_generators.scaffold = :cocoon_scaffold
  #    config.app_generators.orm = :cocoon_model
  #  else
  #    config.generators.scaffold_controller = :cocoon_scaffold_controller
  #    config.generators.scaffold = :cocoon_scaffold
  #    config.generators.orm = :cocoon_model
  #  end
  #end

end
