class PhoneNumberInput < IconInput
  def input
    (input_html_options[:data] ||={})[:mask] = '+27(99)999-9999'
    input_html_options[:data][:placeholder] = ' '
    input_html_options[:icon] = 'icon-phone' unless
        [:icon, :icon_prepend, :icon_append].any? {|k| input_html_options.key? k}
    input_html_options[:icon_title] = 'Telephone number' if input_html_options[:icon_title].nil?
    input_html_options[:type] = 'text'
    #input_html_options[:onfocus] = "javascript:if(this.value=='')this.value='+27(  )   -    ';return false;"
    super
  end

end
