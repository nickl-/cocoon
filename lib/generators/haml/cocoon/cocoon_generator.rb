require 'generators/rails/cocoon_model/cocoon_model_generator'
require 'generators/haml/scaffold/scaffold_generator'

module Haml
  module Generators

    class CocoonGenerator < Haml::Generators::ScaffoldGenerator
      source_root File.expand_path("../templates", __FILE__)
      def process_templates
        recurse singular_name
      end

      protected

      def recurse ref
        Rails::Generators::SchemaAttributes.parse(ref).references.each do |name, ref|
          if ref.references?
            @ref_name = ref
            src = "_view_%ref_name%_fields.html.haml"
            dst = convert_encoded_instructions(
                "app/views/#{table_name}/_view_%ref_name%_fields.html.haml"
            )
            copy_file src, dst
            template src.gsub(/_view/, ''), dst.gsub(/_view/, '')
            append_nested @ref_name.name.dup, recurse(@ref_name.name)
          end
        end
      end

      def available_views
        %w(index edit new _view_nests _view_fields _nests show)
      end

      def references
        Rails::Generators::SchemaAttributes.parse(singular_name).references.values
      end


      def convert_encoded_instructions(filename)
        filename.gsub(/%(.*?)%/) do |initial_string|
          method = $1.strip
          respond_to?(method, true) ? send(method) : initial_string
        end
      end

      def append_nested model, references
        references.each do |c|
          template = "app/views/#{table_name}/_view_#{model}_fields.html.haml"
          append_to_file template do
            "= render 'view_nests', f: item.#{c.pluralize}, nested: '#{c}'"
          end
          append_to_file template.gsub(/_view/, '') do
            "  = render 'nests', f: f, nested: '#{c}'"
          end
        end
      end

      def ref_name
        @ref_name.name
      end

      def ref_attributes
        Rails::Generators::SchemaAttributes.parse(@ref_name.name).accessible.values
      end

      def self_attributes
        Rails::Generators::SchemaAttributes.parse(singular_name).accessible.values
      end

      def title_name
        @title_name ||= singular_name.titleize
      end

      def plural_title_name
        @plural_title_name ||= plural_name.titleize
      end

    end
  end
end
