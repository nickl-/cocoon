require "rails/generators/named_base"

module Css
  module Generators
    Rails::Generators.hidden_namespaces << 'css:cocoon'
    class CocoonGenerator < Rails::Generators::NamedBase
      class_option :skip_bootstrap, :type => :boolean, :default => true,
                   :desc => "Skip installing bootstrap when found. Use --no-skip-bootstrap instead."

      def copy_stylesheet
        if Dir.glob('app/assets/**/bootstrap*').blank? || options[:skip_bootstrap] == false
          js = 'https://raw.github.com/twbs/bootstrap/3.0.0-wip/dist/js/bootstrap.min.js'
          css = 'https://raw.github.com/twbs/bootstrap/3.0.0-wip/dist/css/bootstrap.min.css'
          get js, 'app/assets/javascripts/bootstrap.min.js'
          get css, 'app/assets/stylesheets/bootstrap.min.css'
        else
          say_status :skip,'found bootstrap use --no-skip-bootstrap to install', :yellow
        end
      end
    end
  end
end
