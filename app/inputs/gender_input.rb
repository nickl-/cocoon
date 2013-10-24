class GenderInput < SwitchInput

  def input
    (input_html_options[:data] ||=[])[:data_on] = ''
    input_html_options[:data][:data_off] = ''
    input_html_options[:data][:data_on_label] = "<i class='icon-male'></i>"
    input_html_options[:data][:data_on_label] = "<i class='icon-female'></i>"
    super
  end

end
