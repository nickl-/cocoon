class IconInput < SimpleForm::Inputs::StringInput
  def input
    icon_append = icon_prepend = icon = input_html_options.delete(:icon)
    title = input_html_options.delete(:icon_title)
    prepend = !!input_html_options.delete(:prepend)
    append = !!input_html_options.delete(:append) || !prepend
    if icon.nil?
      append = !!(icon_append = input_html_options.delete(:icon_append))
      prepend = !!(icon_prepend = input_html_options.delete(:icon_prepend))
    end
    out = <<eod
<div class="#{'input-prepend' if prepend}#{' input-prepend-and-append ' if prepend && append}#{'input-append' if append}">
  #{add_on(title, icon_prepend) if prepend}
  #{super}
  #{add_on(title, icon_append) if append}
</div>
eod

    out.html_safe
  end

  private
  def add_on title, icon
    icon = %Q(<i class="#{icon}"></i>) if icon =~ /^icon/
    <<eod
<span class="add-on" title="#{title}">#{icon}</span>
eod
  end
end
