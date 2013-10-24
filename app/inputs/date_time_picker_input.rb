class DateTimePickerInput < SimpleForm::Inputs::StringInput

  def input
    out = <<-eod
<div class="input-append date #{picker_class}" data-date="#{input_html_options[:value]}">
  #{@builder.text_field(attribute_name, input_html_options)}
  <span class="add-on"><i class="#{icon_class}"></i></span>
</div>
eod
    out.html_safe
  end

  protected

  def icon_class
    'icon-calendar'
  end

  def picker_class
    'datetime-picker'
  end

end
