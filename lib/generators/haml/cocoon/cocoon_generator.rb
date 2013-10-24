require 'generators/rails/cocoon_model/cocoon_model_generator'
require 'generators/haml/scaffold/scaffold_generator'
require 'schema_attributes'

module Haml
  module Generators

    class CocoonGenerator < Haml::Generators::ScaffoldGenerator

      def view_ref_chain
        @view_ref_chain ||= []
      end
      def view_entity_count
        @view_entity_count ||= 0
        @view_entity_count += 1
      end
      def ref_chain
        @view_ref_chain ||= []
      end
      def entity_count
        @view_entity_count ||= 0
        @view_entity_count += 1
      end

      source_root File.expand_path("../templates", __FILE__)

      def recurse_nests
        unless defined? @ref_name
          @ref_name = [singular_name]
          template_encoded_instructions "_view_%ref_name%_fields.html.haml"
          template_encoded_instructions "_%ref_name%_fields.html.haml"
          template_encoded_instructions "_grid_%singular_name%_fields.html.haml"
          @ref_name = []
          recurse singular_name
        end
        content = parse_erb_template '_form_actions_helper.erb', instance_eval('binding')
        append_to_file app_views_file_path('_form_layout.html.haml'), content
      end

      def clean_up_views_path
        File.delete app_views_file_path('_form.html.haml') if File.exists? app_views_file_path('_form.html.haml')
      end

      protected

      def recurse ref
        SchemaAttributes.parse(ref).references.each do |name, ref|
          if ref.type == :references
            ref_chain << ref.name
            (@ref_name ||= []) << name.to_s
            src = "_view_%ref_name%_fields.html.haml"
            dst = template_encoded_instructions src
            template src.gsub(/_view/, ''), dst.gsub(/_view/, '')
            template(src.gsub(/_view/, '_grid'), dst.gsub(/_view/, '_grid')) unless ref.has_one?
            content = parse_erb_template '_form_layout_helper.erb', instance_eval('binding')
            append_to_file app_views_file_path('_form_layout.html.haml'), content
            content = parse_erb_template '_view_layout_helper.erb', instance_eval('binding')
            append_to_file app_views_file_path('_view_layout.html.haml'), content
            recurse(ref_name)
            ref_chain.pop
          end
        end
      end

      def available_views
        %w(_view_nests _view_fields _form_nests _grid_nests _sidebar_sections _form_actions _sub_navigation).each { |tpl|
          copy_file "application/#{tpl}.html.haml", "app/views/application/#{tpl}.html.haml" unless
              File.exists? "app/views/application/#{tpl}.html.haml"
        }
        %w(index edit new show _view_layout _form_layout _view)
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
        @ref_name.last
      end

      def ref_attributes
        SchemaAttributes.parse(ref_name).accessible
      end

      def ref_references
        SchemaAttributes.parse(ref_name).references
      end

      def ref_belongs_to
        SchemaAttributes.parse(ref_name).belongs_to.reject {|n,a| n == singular_name || @ref_name.include?(n)}
      end

      def ref_hidden_attributes
        SchemaAttributes.parse(ref_name).hidden
      end

      def self_attributes
        SchemaAttributes.parse(singular_name).accessible
      end

      def grid_attributes
        ref_attributes.values + ref_hidden_attributes.values
      end

      def title_name
        @title_name ||= singular_name.titleize
      end

      def plural_title_name
        @plural_title_name ||= plural_name.titleize
      end

      def template_encoded_instructions tpl
        dst = convert_encoded_instructions(app_views_file_path(tpl))
        template tpl, dst
        dst
      end

      def app_views_file_path file
        "app/views/#{SchemaAttributes.path}#{plural_name}/#{file}"
      end

      def parse_erb_template template_file, bindings
        ERB.new(
          ::File.binread(File.expand_path(find_in_source_paths(template_file))),
          nil, '-', '@output_buffer'
        ).result(bindings)
      end

    end
  end
end
