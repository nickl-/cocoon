class Cocoonase::Inputs::PercentageInput < Cocoonase::Inputs::IconInput
  def input
    input_html_options[:type] = 'number'
    input_html_options[:placeholder] ||= "0.0"
    input_html_options[:max] = 100.0
    input_html_options[:min] = 0.1
    input_html_options[:step] = 0.1

    input_html_options[:icon] = '%'
    input_html_options[:style] = 'text-align: right'
    input_html_options[:icon_title] = 'Percentage'

    input_field = super
    input_id = input_field[/ id="(\w*)/, 1]
    <<-eod
#{input_field}
<script type="application/javascript">
var previousValue;
var previousFormats;


(function($) {
  $('##{input_id}').change(function () {
    this.value = parseFloat(this.value).toFixed(1);
    this.validate;
    //this.value = numeral(this.value).format('0.00');
} );

})(jQuery);

</script>
eod
  end

end
