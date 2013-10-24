class Cocoonase::Inputs::DateTimePickerInput < SimpleForm::Inputs::StringInput

  def input
    out = '<div class="input-append date '+picker_class+'" data-date="'+"#{input_html_options[:value]}"+'">'
    out << @builder.text_field(attribute_name, input_html_options)
    out << '<span class="add-on"><i class="'+icon_class+'"></i></span>'
    out << "</div>"
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
