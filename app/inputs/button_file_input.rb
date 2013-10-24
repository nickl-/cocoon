class Cocoonase::Inputs::ButtonFileInput < SimpleForm::Inputs::FileInput
  include ApplicationHelper
  include ActionView::Helpers::AssetTagHelper

  def input
    field_value = input_html_options[:data][:value] ?
        input_html_options[:data].delete(:value) :
        input_html_options[:value]
    Rails.logger.info "----------------------------------------------------> field_value.path"
    field_type = input_html_options[:data][:uploadtype] || (field_value.path =~ /\.png$|\.jpe?g$|\.gif$/i ? 'image' : 'file')
    field_preview = ''
    field_preview = string_view(field_value, field_value.model.class.columns_hash['payload']) if field_type == 'file'
    field_preview = link_to(image_tag("#{payload_url(field_value)}?thumb=1"), payload_url(field_value)) if field_type == 'image'

    out = <<eod
<div class="fileupload #{ field_value.blank? ? 'fileupload-new' : 'fileupload-exists' }" data-provides="fileupload">
  <span class="btn btn-file"><span class="fileupload-new">Select #{field_type}</span>
    <span class="fileupload-exists">Change</span>#{ super }</span>
  <span class="fileupload-preview fileupload-exists#{' thumbnail" style="width: 70px; height: 100px;' if field_type == 'image'}">
    #{ field_preview }
  </span>
  <a href="#" class="close fileupload-exists" data-dismiss="fileupload" style="float: none">×</a>
</div>
eod

    out.html_safe
  end

  def default_url_options
    {}
  end

  def controller
    :service_action
  end
end
