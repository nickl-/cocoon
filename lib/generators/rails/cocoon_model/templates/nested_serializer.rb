<% module_namespacing do -%>
class <%= class_name %>Serializer < ActiveModel::Serializer
<% attributes_names.map(&:inspect).each do |att| -%>
  attribute <%= att %><%= att =~ /_/ ? ", key: #{att.camelize(:lower)}" : '' %>
<% end -%>
end
<% end -%>
