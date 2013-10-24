class SwitchInput < SimpleForm::Inputs::BooleanInput

  def input
    data_on = (input_html_options[:data] ||=[]).delete(:data_on) || 'success'
    data_off = input_html_options[:data].delete(:data_off) || ''
    data_on_label = input_html_options[:data].delete(:data_on_label) || "<i class='icon-ok icon-white'></i>"
    data_off_label = input_html_options[:data].delete(:data_off_label) || "<i class='icon-remove'></i>"
    out = <<-eod
<div class="make-switch" data-on-label="#{data_on_label}"  data-on="#{data_on}" data-off-label="#{data_off_label}"  data-off="#{data_off}" tabindex="0">
  #{@builder.check_box(attribute_name, input_html_options)}
</div>
eod
    out.html_safe
  end

end
