class Cocoonase::Inputs::ButtonRadioInput < SimpleForm::Inputs::CollectionRadioButtonsInput
  def input
    out = <<-HTML

<div class="btn-group" data-toggle="buttons-radio">
HTML
    input_field = @builder.hidden_field(attribute_name, input_html_options)
    input_id = input_field[/ id="(\w*)/, 1]
    label_method, value_method = detect_collection_methods
    collection.each {|item|
      value = item.send(value_method)
      label = item.send(label_method)
      on_click = "document.getElementById('#{input_id}').value='#{value}';return false;"
      active = ''
      active = ' active' unless
          out =~ / active/ ||
          input_html_options[:value] != value &&
          item != collection.last
      input_html_options[:value] = value unless active.empty?
      btn = 'btn'
      btn = "btn btn-#{item.third}" unless item.third.nil?
      out << <<-HTML
  <button onclick="javascript:#{on_click}" type="button" class="#{btn}#{active}">#{label}</button>
HTML
    }
    value = <<-VAL
value="#{input_html_options[:value]}"
VAL
    input_field[/value="[^"]*"/] = value.chomp if input_field =~ /value/
    input_field[/input/] = "input #{value.chomp}" unless input_field =~ /value/
    out << <<-HTML
  #{input_field}
</div>
HTML
    out.html_safe
  end
end
