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

  def xeditable?
    true # Or something like current_user.xeditable?
  end

  protected
  def collection
    @<%= plural_name %> ||= end_of_association_chain.page(params[:page]).per(15)
  end

  def build_resource_params
    [params.require(:<%= singular_table_name %>).permit(
      [:_destroy, :id<%= permissible_attributes.blank? ? '' : ", #{permissible_attributes}" %><%= strong_parameters %>]
    )] if params[:<%= singular_table_name %>].present?
  end

end
