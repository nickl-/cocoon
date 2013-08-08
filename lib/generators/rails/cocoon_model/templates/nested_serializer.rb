<% module_namespacing do -%>
class <%= class_name %>Serializer < ActiveModel::Serializer
  attributes <%= attributes_names.map(&:inspect).join(", ") %>
end
<% end -%>
