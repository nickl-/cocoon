class FaxNumberInput <PhoneNumberInput
  def input
    input_html_options[:icon] = 'icon-print'
    input_html_options[:icon_title] = 'Fax number'
    super
  end

end
