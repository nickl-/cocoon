class <%= controller_class_name %>Controller < InheritedResources::Base
  require Rails.root.join 'lib/application_responder'
  self.responder = ApplicationResponder
  respond_to :html, :xml, :json

  protect_from_forgery

<% if options[:singleton] -%>
  defaults :singleton => true
<% end -%>

  def can? action, type
    true
  end

  protected
  def collection
    @<%= plural_table_name %> ||= end_of_association_chain.page(params[:page]).per(15)
  end

  def build_resource_params
    [params.require(:<%= singular_name %>).permit(
      [<%= permissible_attributes %><%= strong_parameters %>]
    )] if params[:<%= singular_name %>].present?
  end

end