class Cocoonase::Inputs::SwitchInput < SimpleForm::Inputs::BooleanInput

  def input
    data_on = (input_html_options[:data] ||=[]).delete :data_on || 'success'
    data_off = (input_html_options[:data] ||=[]).delete :data_on || ''
    data_on_label = (input_html_options[:data] ||=[]).delete :data_on_label || "<i class='icon-ok icon-white'></i>"
    data_off_label = (input_html_options[:data] ||=[]).delete :data_on_label || "<i class='icon-remove'></i>"
    out = <<-eod
<div class="make-switch" data-on-label="#{data_on_label}"  data-on="#{data_on}" data-off-label="#{data_off_label}"  data-off="#{data_off}">
  #{super}
</div>
eod
    out.html_safe
  end

end
