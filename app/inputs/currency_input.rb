class CurrencyInput < SimpleForm::Inputs::NumericInput
  def input
    input_html_options[:placeholder] ||= "0.00"
    input_html_options[:step] = 0.01
    input_field = super
    input_id = input_field[/ id="(\w*)/, 1]
    input_html_options[:currency] ||= currency
    out = <<-HTML
<div class="input-prepend input-prepend-and-append input-append">
  <span class="add-on">#{input_html_options[:currency]}</span>
  #{input_field}
  <span class="add-on">&nbsp;</span>
  <script type="text/javascript">
    (function (document) {
      function currency_value () {
        this.value = parseFloat(this.value).toFixed(2);
        this.validate
      }
      var el = document.getElementById('#{input_id}');
      if (el.addEventListener) {
        el.addEventListener('blur', function () { this.step = 0.01; }, false);
        el.addEventListener('change', function () {
          this.step = Math.max(Math.pow(10,this.value.length-5), 0.05);
        }, false);

        el.addEventListener('DOMContentLoaded', currency_value, false);
        el.addEventListener('blur', currency_value, true);
        el.addEventListener('change', currency_value, true);
      } else if (el.attachEvent) {
        el.attachEvent('blur', function () { this.step = 'any'; }, false);
        el.attachEvent('change', function () {
          //this.step = Math.max(Math.pow(10,this.value.length-3)/100, 0.05);
        }, false);

        el.attachEvent('DOMContentLoaded', currency_value, false);
        el.attachEvent('blur', currency_value, true);
        el.attachEvent('change', currency_value, true);
      }
      el.value = parseFloat(el.value).toFixed(2);
    })(window.document);
  </script>
</div>
HTML
    out.html_safe
  end

  def currency val=nil
    @currency = val unless val.nil?
    @currency ||= 'R'
  end
end
