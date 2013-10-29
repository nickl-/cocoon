class LookupSelectInput < SimpleForm::Inputs::Base

  def input
    Rails.logger.info '-------------------------------------'
    Rails.logger.info input_html_options
    Rails.logger.info '-------------------------------------'
    list_url = input_html_options.delete(:list_url)
    input_field = @builder.hidden_field(attribute_name, input_html_options)
    input_id = input_field[/ id="(\w*)/, 1]
    out = <<-eod
#{input_field}
<div id="#{input_id}_waiting" class="progress progress-striped active">
  <div class="bar" style="width: 100%;"></div>
</div>
<script type="text/javascript">
  (function ($) {
    if (!store.get('target_list'))
            request.get('#{list_url}').accept('json').end(function (res) {
                if (res.ok)
                    if (store && store.enabled)
                        store.set('target_list', res.body);
                $('##{input_id}_waiting').hide();
                $('##{input_id}').select2({data: {results: store.get('target_list')}});

            });
    else {
      $('##{input_id}_waiting').hide();
      $('##{input_id}').select2({data: {results: store.get('target_list')}});
    }

  })(window.jQuery);
</script>
eod
    out.html_safe
  end

end
