require 'generators/haml/scaffold/scaffold_generator'

module Haml
  module Generators
    class RefName
      attr_accessor :name, :relationship
      def initialize(n, r='')
        self.relationship= r
        self.name= n.singularize unless self.has_one?
        self.name= n if self.has_one?
      end
      def has_one?
        not (self.relationship =~ /has_one/).nil?
      end
      def has_many?
        not (self.relationship =~ /has_many/).nil?
      end
    end
    class CocoonGenerator < Haml::Generators::ScaffoldGenerator
      source_root File.expand_path("../templates", __FILE__)

      protected

      def available_views
        references
        %w(index edit new _view_nests _view_fields _nests show)
      end

      def references
        @references ||= recurse RefName.new(singular_table_name)
      end

      def recurse ref
        references = []
        @_source_root ||= File.expand_path("../templates", __FILE__)
        File.read("app/models/#{ref.name}.rb").lines do |line|
          if line =~ /has_many :|has_one :/
            @ref_name = RefName.new(*line[/has\w* :\w*/].split(' :').reverse)
            src = "_view_%ref_name%_fields.html.haml"
            dst = convert_encoded_instructions(
                "app/views/#{table_name}/_view_%ref_name%_fields.html.haml"
            )
            copy_file src, dst
            template src.gsub(/_view/, ''), dst.gsub(/_view/, '')
            references.append @ref_name.dup
            append_nested @ref_name.name.dup, recurse(@ref_name.dup)
          end
        end
        references
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
        reject_attributes Kernel.const_get(ref_name.camelize).columns_hash
      end

      def self_attributes
        @self_attributes ||= reject_attributes Kernel.const_get(class_name).columns_hash
      end

      def reject_attributes hash
        hash.reject {|name, a| name.blank? || name =~ /id$|at$/}
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
