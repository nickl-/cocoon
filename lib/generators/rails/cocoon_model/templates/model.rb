<% module_namespacing do -%>
class <%= class_name %> < <%= parent_class_name.classify %>
<% if scope_attributes.include? 'payload' -%>
  include UploadDocument
<% end -%>
<% attributes.select(&:reference?).each do |attribute| -%>
  belongs_to :<%= attribute.name %><%= ', polymorphic: true' if attribute.polymorphic? %>
<% end -%>
<% attributes.select(&:has_and_belongs_to_many?).each do |attribute| -%>
has_and_belongs_to_many :<%= attribute.plural_name %>
<% end -%>
<% if attributes.any?(&:password_digest?) -%>
  has_secure_password
<% end -%>

<% scope_attributes.each do |name| -%>
  scope :by_<%= name %>, lambda {|ref| where <%= name %>: ref }
<% end -%>

  has_paper_trail
end
<% end -%>
