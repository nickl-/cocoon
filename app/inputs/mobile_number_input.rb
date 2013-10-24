class Cocoonase::Inputs::MobileNumberInput < Cocoonase::Inputs::PhoneNumberInput
  def input
    input_html_options[:icon] = 'iconic-iphone'
    input_html_options[:icon_title] = 'Cel phone number'
    super
  end

end
