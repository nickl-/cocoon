class NumberInput < IconInput
  def input
    input_html_options[:type] = 'number'
    input_html_options[:icon] = '&nbsp;'.html_safe
    input_html_options[:style] = 'text-align: right'
  end

end
