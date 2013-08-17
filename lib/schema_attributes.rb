require 'generators/rails/cocoon_model/cocoon_model_generator'
class SchemaAttributes < Hash
  attr_accessor :model
  @@path = nil
  def path
    @@path
  end

  class << self

    def path
      return '' if @@path.nil?
      @@path
    end

    def parse(pmodel)
      model = real_model(pmodel)
      (@@cached_atts ||= {})[model] ||= begin
        table_data = _filter_lines(
          _read_files(model,
          _model_schema_paths(model))).map {|att|
            str = to_script(*att)
            [att[1].singularize, Rails::Generators::GeneratedAttribute.parse(str)] unless str.nil? || att[1].nil?
        }
        (schema_attributes = SchemaAttributes[table_data.reject(&:blank?)]).model= model
        schema_attributes
      end
    end

    def real_model(pmodel)
      model = ns_model = pmodel.to_s.singularize
      model = model.split('/').pop if model =~ /\//
      @@path ||= ns_model.chomp(model)
      model
    end

    def populate(name, attributes)
      sa = SchemaAttributes.new
      sa.model= real_model name
      (@@cached_atts ||= {})[name] = sa.merge! attributes
    end

    private

    def table_name name
      return "#{path.gsub(/\//,'_')}#{name.pluralize}" if
          (!defined?(ActiveRecord::Base) || ActiveRecord::Base.pluralize_table_names)
      "#{path.gsub(/\//,'_')}#{name}"
    end

    def to_script(*args)
      type, name, assoc = args
      %w(has_one has_many).include? type and
          assoc = type and
          type = 'references'

      "#{name}:#{type}" + (assoc.blank? ? '' : ":#{assoc}")
    end

    def _model_schema_paths(model)
      Dir.glob("db/migrate/*#{table_name model}.rb") + ['db/schema.rb', "app/models/#{path}#{model}.rb"]
    end

    def _read_files(model, paths)
      ((paths.map {|f|
        File.read(f)[/(?:.*table "?:?#{table_name model}.*|class #{model.camelize}.*)([\s\S]*?)(?=^\s*end\s*$)/, 1] if File.exist?(f)
      }) * '').lines
    end

    def _filter_lines(lines)
      before = ''
      (lines.map {|l|
        l = "#{l}  :#{before[2]}" unless before.blank?
        before = l.match(/# (\w*):-*(\w*)-*<:(\w*)/)
        l.gsub(/^\s*$|t.timestamps|.*_id.*|.*paper.*|t\.|accepts_.*|, dep.*|^\s*$|"|:|,|#.*/,'')
      }).reject(&:blank?).map(&:split)
    end

  end
  def merge!(*several_variants)
    super *several_variants
    replace Hash[map { |m,t|
      t.name = t.name.singularize.pluralize if references? t.name and t.has_many?
      [m.to_s.singularize.to_sym, t]
    }]
    #rehash
    (@@cached_atts ||= {})[model] = self unless model.blank?
    self
  end

  def relationship ref
    self[ref].relationship if self[ref]
  end

  def belongs_to? ref
    !self[ref].nil? && self[ref].type == :belongs_to
  end

  def has_one? ref
    !self[ref].nil? && self[ref].relationship == :has_one
  end

  def name_for ref
    self[ref].name unless self[ref].nil?
  end

  def references? ref
    !self[ref].nil? && self[ref].type == :references
  end

  def references
    select {|name, att| references? name}
  end

  def belongs_to
    select {|name, att| belongs_to? name}
  end

  def accessible
    reject {|name, att| name.nil? ||
      %w(created_at updated_at created_by updated_by).include?(name) ||
        belongs_to?(name) ||
        references?(name)}
  end

  def permissible
    names = ''
    belongs_to.values.each { |att| names << ":#{att.name}_id, " }
    accessible.values.each { |att| names << ":#{att.name}, " }
    names.chomp(', ')
  end
end
