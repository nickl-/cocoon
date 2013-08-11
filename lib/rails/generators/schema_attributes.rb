require 'generators/rails/cocoon_model/cocoon_model_generator'
module Rails
  module Generators
    class SchemaAttributes < Hash
      attr_accessor :model

      class << self

        def parse(model)
          (@@cached_atts ||= {})[model] ||= begin
            table_data = _filter_lines(
              _read_files(model,
              _model_schema_paths(model))).map {|att|
                str = to_script(*att)
                [att[1], GeneratedAttribute.parse(str)] unless str.nil?
            }
            (schema_attributes = SchemaAttributes[table_data.reject(&:blank?)]).model= model
            schema_attributes
          end
        end

        def populate(name, attributes)
          sa = SchemaAttributes.new
          sa.model= name
          (@@cached_atts ||= {})[name] = sa.merge! attributes
        end

        private

        def table_name name
          return name.pluralize if
              (!defined?(ActiveRecord::Base) || ActiveRecord::Base.pluralize_table_names)
          name
        end

        def to_script(*args)
          type, name, assoc = args
          %w(has_one has_many).include? type and
              assoc = type and
              type = 'references'

          "#{name}:#{type}" + (assoc.blank? ? '' : ":#{assoc}")
        end

        def _model_schema_paths(model)
          Dir.glob("db/migrate/*#{table_name model}.rb") + ['db/schema.rb', "app/models/#{model}.rb"]
        end

        def _read_files(model, paths)
          ((paths.map {|f|
            File.read(f)[/(?:.*table "?:?#{table_name model}.*|class #{model.camelize}.*)([\s\S]*?)(?=end)/, 1]
          }) * '').lines
        end

        def _filter_lines(lines)
          before = ''
          (lines.map {|l|
            l = "#{l}  :#{before[2]}" unless before.blank?
            before = l.match(/# (\w*):-*(\w*)-*<:(\w*)/)
            l.gsub(/^\s*$|t.timestamps|t\.|accepts_.*|, dep.*|"|:|,|#.*/,'')
          }).reject(&:blank?).map(&:split)
        end

      end
      def merge!(*several_variants)
        super *several_variants
        (@@cached_atts ||= {})[model] = self unless model.blank?
        self
      end

      def relationship ref
        self[ref].relationship if self[ref]
      end

      def belongs_to? ref
        !self[ref].nil? && self[ref].belongs_to?
      end

      def references? ref
        !self[ref].nil? && self[ref].references?
      end

      def references
        select {|name, att| att.reference?}
      end

      def accessible
        reject {|name, att| %w(created_at updated_at).include? name}
      end

      def permissible
        names = ''
        accessible.keys.reject(&:blank?).each { |name| names << ":#{name}, " }
        names.chomp(', ')
      end
    end
  end
end
