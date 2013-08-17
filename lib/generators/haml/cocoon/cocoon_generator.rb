require 'generators/rails/cocoon_model/cocoon_model_generator'
require 'generators/haml/scaffold/scaffold_generator'
require 'schema_attributes'

module Haml
  module Generators

    class CocoonGenerator < Haml::Generators::ScaffoldGenerator
      source_root File.expand_path("../templates", __FILE__)

      protected

      def recurse ref
        SchemaAttributes.parse(ref).references.each do |name, ref|
          if ref.type == :references
            @ref_name = name
            src = "_view_%ref_name%_fields.html.haml"
            dst = convert_encoded_instructions(
                "app/views/#{SchemaAttributes.path}#{plural_name}/_view_%ref_name%_fields.html.haml"
            )
            template src, dst
            template src.gsub(/_view/, ''), dst.gsub(/_view/, '')
            recurse(ref_name)
          end
        end
      end

      def available_views
        recurse singular_name unless defined? @ref_name
        %w(_view_nests _view_fields _nests _sidebar_sections).each { |tpl|
          copy_file "application/#{tpl}.html.haml", "app/views/application/#{tpl}.html.haml"
        }
        %w(index edit new show)
      end

      def references
        @references ||= SchemaAttributes.parse(singular_name).references
      end

      def belongs_to
        @belongs_to ||= SchemaAttributes.parse(singular_name).belongs_to
      end


      def convert_encoded_instructions(filename)
        filename.gsub(/%(.*?)%/) do |initial_string|
          method = $1.strip
          respond_to?(method, true) ? send(method) : initial_string
        end
      end

      def ref_name
        @ref_name.to_s
      end

      def ref_attributes
        SchemaAttributes.parse(ref_name).accessible
      end

      def ref_has_one
        SchemaAttributes.parse(singular_name).has_one? ref_name
      end

      def ref_references
        SchemaAttributes.parse(ref_name).references
      end

      def ref_belongs_to
        SchemaAttributes.parse(ref_name).belongs_to.reject {|n,a| n == singular_name}
      end

      def self_attributes
        SchemaAttributes.parse(singular_name).accessible
      end

      def self_belongs_to
        SchemaAttributes.parse(singular_name).belongs_to
      end

      def title_name
        @title_name ||= singular_name
      end

      def plural_title_name
        @plural_title_name ||= plural_name
      end

    end
  end
end
