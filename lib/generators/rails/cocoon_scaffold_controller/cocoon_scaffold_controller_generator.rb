module Rails
  module Generators
    require 'rails/generators/rails/scaffold_controller/scaffold_controller_generator'
    require 'schema_attributes'

    class CocoonScaffoldControllerGenerator < Rails::Generators::ScaffoldControllerGenerator
      source_root File.expand_path("../templates", __FILE__)
      remove_hook_for :template_engine
      hook_for :template_engine, as: :cocoon

      def application_responder
        return copy_file 'application_responder.rb', 'lib/application_responder.rb' unless
            File.exists? 'lib/application_responder.rb'
        say_status :exist, 'lib/application_responder.rb', :blue
      end

      protected
      def by_attributes
        SchemaAttributes.parse(singular_name).accessible.values.map {|v| ":by_#{v.name}"} *', '
      end

      def strong_parameters
        say_status :insert, 'injecting strong parameters', :blue
        recurse_references singular_name, '  '
      end

      def recurse_references(model, indent)
        ret = ''
        SchemaAttributes.parse(model).references.each do |name, att|
              indentation = indent
              attribute_name = att.name
              permissible = SchemaAttributes.parse(name).permissible
              recurse = recurse_references(name, indent+'  ')
              source  = File.expand_path(find_in_source_paths('strong_parameters.erb'))
              context = instance_eval('binding')
              ret << ERB.new(::File.binread(source), nil, '-', '@output_buffer2').result(context).chomp
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
