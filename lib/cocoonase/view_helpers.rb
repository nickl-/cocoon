require 'rails/generators/generated_attribute'
module Cocoonase
  module ViewHelpers
    #include ActionView::Helpers::UrlHelper
    #include Rails.application.routes.url_helpers

    def t_icon key, options={}
      icon = options.delete(:icon)
      "<i class='#{icon}'></i>&nbsp;#{t(key, options)}".html_safe
    end

    def action_link key, options={}
      link_to t_icon(key, default: options.delete(:default), icon: options.delete(:icon)), options.delete(:path), options
    end

    def action_grid_button key, btn_type, options={}
      options[:class] = "btn btn-#{btn_type} btn-mini"
      action_link key, options
    end

    def action_grid_show item, options={}
      action_grid_button '.show', 'primary', { default: 'Show', icon: 'fa fa-file-text-o icon-2x', path: resource_url(item) }.deep_merge(options)
    end

    def action_grid_edit item, options={}
      action_grid_button '.edit', 'success', { default: 'Edit', icon: 'fa fa-edit icon-2x', path: edit_resource_url(item) }.deep_merge(options)
    end

    def action_grid_destroy item, options={}
      action_grid_button '.destroy', 'danger', { default: 'Destroy', icon: 'icon-remove icon-2x',
          path: resource_url(item), data: { confirm: t('.confirm_destroy', default: 'Are you sure?') }, method: :delete }.deep_merge(options)
    end

    def resource_name
      @_controller.class.name.underscore[/\/?(\w+)_controller$/,1].singularize
    end

    def parent_name
      parent.class.name.underscore[/\/?(\w+)$/,1]
    end

    def action_nav_new page
      options = {
          default: "New #{resource_name.humanize}",
          path: new_resource_url,
          icon: 'fa fa-file-o',
      }
      content_tag 'li', action_link(".new_#{resource_name}", options), class: "#{'active' if page == 'new'}"
    end

    def action_nav_all page
      options = {
          default: "All #{resource_name.humanize.pluralize}",
          path: collection_url,
          icon: 'iconic-document-stroke',
      }
      content_tag 'li', action_link(".all_#{resource_name}", options), class: "#{'active' if page == 'all'}"
    end

    def action_nav_edit page
      return if %w(new all).include?(page)
      options = {  default: "Edit This #{resource_name.humanize}",
                   icon: 'fa fa-edit',
                   path: edit_resource_url
      }
      content_tag 'li', action_link(".edit_#{resource_name}", options),
          class: "#{'active' if page == 'edit'}"
    end

    def action_nav_show page
      return if %w(new all).include?(page)
      options = { default: "Show This #{resource_name.humanize}",
                  icon: 'fa fa-file-text-o',
                  path: resource_url
      }
      content_tag 'li', action_link(".edit_#{resource_name}", options),
          class: "#{'active' if page == 'show'}"
    end

    def action_nav_back
      return unless request.referrer
      back_title = request.referrer[/\/(\w+)\??[^\/]*$/,1]
      back_title = request.referrer[/\/([^\/]+)\/#{back_title}/,1].singularize if back_title =~ /\d/
      content_tag('li', action_link('.go_back', default: "Back to #{back_title.humanize.downcase}",
         icon: 'fa fa-hand-o-left', path: request.referrer)) unless back_title.nil?
    end

    def action_nav_up
      content_tag('li', action_link('.go_back', default: "Up to #{parent_name.humanize}",
         icon: 'fa fa-hand-o-up', path: parent_url)) if !!defined?(parent)
    end

    def nav_menu name
      tabs(name)[/.*tabs">(.*)<\/ul>/m,1]
    end

    def nav_user name
      return nav_menu(name) unless user_signed_in?
      nav_menu(name).sub(/users\/sign_out"/,'users/sign_out" data-method="delete"').gsub(/li/,'li class="devise"').html_safe
    end

    def nav_menu_long name
      tabs(name)[/.*tabs">(.*)<\/ul>/m,1].gsub(/<ul class="dropdown-menu/,'<div class="arrow-up dropdown-menu"></div><ul class="dropdown-menu scroll-menu').html_safe
    end

    def build_nested_form_fields f, ref_chain, &block
      if ref_chain.empty?
        yield f
        ''
      else
        chain = ref_chain.split('.')
        ref = chain.shift
        if f.object.respond_to? ref
          f.object.send("build_#{ref}") if f.object.send(ref).nil?
          f.simple_fields_for ref.to_sym do |nf|
            if nf.object.respond_to? :each
              nf.object.build if nf.object.empty?
              nf.object.each do |nfo|

                build_nested_form_fields nf, chain.join('.'), &block
              end
            else
              build_nested_form_fields nf, chain.join('.'), &block
            end
          end
        else
          simple_form_for resource do |f|
            build_nested_form_fields f, chain.join('.'), &block if
                f.object.respond_to? ref
          end
        end
      end
    end

    def build_nested_view_fields s, ref_chain, &block
      return yield s  if ref_chain.empty?
      chain = ref_chain.split('.')
      ref = chain.shift
      if s.object.respond_to? ref
        s.object.send("build_#{ref}") if s.object.send(ref).nil?
        if s.object.send(ref).respond_to? :each
          s.object.send(ref).each do |item|
            show_for item do |ns| s = ns; end
            build_nested_view_fields s, chain.join('.'), &block
          end
        else
          show_for s.object.send(ref) do |ns| s = ns; end
          build_nested_view_fields s, chain.join('.'), &block
        end
      else
        show_for resource do |ns| s = ns; end
        chain.unshift ref
        build_nested_view_fields s, chain.join('.'), &block if
            s.object.respond_to? ref
      end
    end

    def mappings
      @@mappings
    end

    def self.map_type(*types)
      map_to = types.extract_options![:to]
      raise ArgumentError, "You need to give :to as option to map_type" unless map_to
      @@mappings = (@@mappings ||= {}).merge types.each_with_object({}) { |t, m| m[t] = map_to }
    end

    map_type :text,                                           to: 'wysihtml5'
    map_type :string, :password, :email, :search, :tel, :url, to: 'text'
    map_type :integer, :decimal, :float,                      to: 'number'
    map_type :select, :radio, :check_boxes,                   to: 'select2'
    map_type :date, :time, :datetime,                         to: 'datetime'
    #map_type :country, :time_zone,                            to: SimpleForm::Inputs::PriorityInput
    map_type :boolean,                                        to: 'switch'


    def inline_input object, name, *args
      obj = [*object].last
      model = obj.class
      if can?(:edit, model) #&& xeditable?
        meta, type, value, options = args
        nme = name.split('.').last
        value = obj.send(nme) if (value.nil? || value.is_a?(Hash)) && (options = value || {})
        meta = model.columns_hash[nme] if meta.is_a?(Hash) && (options = meta || {})
        options = type if options.blank? && type.is_a?(Hash)
        type = (meta.nil? ? 'string' : meta.type) if type.nil? || type.is_a?(Hash)
        model_param = model.name.to_s.underscore.gsub('/', '_')
        type = meta.nil? ? 'string' : meta.type
        options = {} if options.nil?
        data_url = polymorphic_path([*object].first)
        empty = '&nbsp;'.html_safe
        content_tag(
            :a,
            options[:value] ? options[:value] : value,
            href: "#",
            class: "editable#{ ' editable-empty' if value.blank? }",
            data: {
                type: (options[:type] ? options[:type] : mappings[type]), #text|textarea|select|date|checklist|wysihtml5|password|email|url|tel|number|range|checklist|typeahead|select2
                model: model_param,
                name: name,
                url: data_url,
                placeholder: '',
                defaultValue: empty,
                emptytext: empty,
                autotext: 'always',
                mode: 'inline', # popup|inline
                placement: 'top', # top|right|bottom|left
                highlight: '#FFFF80',
                onblur: 'cancel', # cancel|submit|ignore
                send: 'always', # auto|always|never
                toggle: 'click', #click|dblclick|mouseenter|manual
                #nested: (nested_parts[0] if nested),
                #nid: (n_object.id if nested),
                nids: [*object].map {|o| o.id},
                has_one: [*object].length == 1,
                pk: (options[:pk] ? options[:pk] : obj.id),
                anim: '100',
                ajaxOptions: {
                    type: 'put',
                    dataType: 'json'
                },
                'original-title' => t(".#{nme}", default: nme.titleize)
            }
        )
      else
        options[:e]
      end
    end


    def display_base_errors resource
      return '' if (resource.errors.empty?) or (resource.errors[:base].empty?)
      messages = resource.errors[:base].map { |msg| content_tag(:p, msg) }.join
      html = <<-HTML
      <div class="alert alert-error alert-block">
        <button type="button" class="close" data-dismiss="alert">&#215;</button>
        #{messages}
      </div>
      HTML
      html.html_safe
    end

  # View metas
  ##################################
    def custom object, name, kind = 'view'
      value = object.respond_to?(name) ? object.send(name) : object.respond_to?(name.pluralize) ? object.send(name.pluralize) : nil
      value = value.id if value.respond_to?(:id)
      meta = object.class.columns_hash[name] unless object.nil?
      type = meta.nil? ? value.class.name : meta.type
      meta = Rails::Generators::GeneratedAttribute.parse("#{name}:#{type}") if meta.nil?

      #is_inline = !!(kind = 'view' if kind == 'inline')

      if respond_to?("#{type}_#{kind}")
        value = send("#{type}_#{kind}", value, meta)
      elsif kind == 'edit'
        value = _options(value, meta) unless kind  == 'view' || value.is_a?(Hash)
      end
      #value = '&nbsp;'.html_safe if kind  == 'view' && value.blank?


      #return inline_input(objects, names, meta, type, value) if is_inline

      value
    end

    def custom_view object, name
      custom object, name
    end

    def custom_inline object, name
      custom object, name, 'inline'
    end

    def custom_edit object, name
      custom object, name, 'edit'
    end

    def custom_edit_opt object, name
      custom(object, name, 'edit').deep_merge({ input_html: { required: false }})
    end

    def boolean_view value, meta
      return '<i class="iconic-o-check alert-success icon-2x"></i>'.html_safe if value
      '<i class="iconic-o-x icon-2x"></i>'.html_safe
    end

    def datetime_view value, meta=nil
      return value.strftime "%Y-%m-%d %H:%M:%S" unless value.nil?
      ''
    end

    #def time_with_zone_view meta, value
    #  datetime_view meta, value
    #end

    def date_view value, meta=nil
      return value.strftime "%Y-%m-%d" unless value.nil?
      ''
    end

    def time_view value, meta=nil
      return value.strftime "%H:%M:%S" unless value.nil?
      ''
    end

    def string_view value, meta
      return if value.blank? || meta.nil?
      col = collection_for_name(meta.name)
      col = col[:collection] unless  col.empty? || col[:collection].nil?
      col.each { |k,v| value = k if value == v }
      case meta.name
        when 'link'
          link_to '<i class="iconic-link"></i> ACK'.html_safe, 'javascript:void(0);', data: {url: value}, onclick: "acknowledge(this);return false;"
        when 'bondIndicator', 'instruction', 'MLA'
          boolean_view value == 'Y', meta
        when 'payload'
          link_to "<i class=#{'"iconic-download"'}></i> #{value.file.path[/([^\/]*)$/, 1]}".html_safe, payload_url(value), title: 'download'
        when /email/i, /e_mail/i
          "#{'<i class="fa fa-envelope-o"></i>'} #{mail_to value}".html_safe
        when  /.*amount.*/i, /.*deposit.*/i, /.*price.*/i, /.*cost.*/i, /.*cash.*/i, /.*interest$/i, /.*payment.*/i, /.*fee.*/i, /.*debt.*/i, /.*premium.*/i
          number_to_currency value, unit: 'R', separator: '.'
        when  /.*rate$/i, /.*percent.*/i, /variance/i
          number_to_percentage value, format: "%n %", precision: 2
        when /.*fax.*/i
          "#{'<i class="fa fa-print"></i>'} #{value}".html_safe
        when /.*mobile.*/i, /.*cel.*/i
          "#{'<i class="iconic-iphone"></i>'} #{value}".html_safe
        when  /.*tel.*/i, /.*phone.*/i
          "#{'<i class="fa fa-phone"></i>'} #{value}".html_safe
        else
          value

      end
    end

    def decimal_view value, meta
      string_view value, meta
    end

    def integer_view value, meta
      string_view value, meta
    end

    def float_view value, meta
      string_view value, meta
    end

    def text_view value, meta
      value.nil? ? '' : value.html_safe
    end

  #Editable
  ##################################
  #  def editable value, model, meta
  #    {
  #        type: meta.type,
  #        model: '<%= singular_name %>', name: 'name', url: post_path(post), 'original-title' => 'Your info here'}}= post.name
  #  end

  # Edit metas
  ##################################

    def _options value, meta
      options = {
        input_html: {
          value: value,
          required: !(defined?(optional_params) && optional_params.include?(meta.name.to_sym)) &&
                    !%w(reason).include?(meta.name),
        }
      }
      options[:maxlength] = meta.limit if meta.respond_to?('limit') && meta.limit && meta.type == 'string'
      options[:readonly] = %w(id created_at updated_at created_by updated_by).include? meta.name
      options
    end


    def datetime_edit value, meta
      _options(value, meta).deep_merge({
        as: :date_time_picker,
        input_html: {
          value:  datetime_view(value),
        }
      })
    end

    def date_edit value, meta
      _options(value, meta).deep_merge({
        as: :date_picker,
        input_html: {
          value: date_view(value),
        }
      })
    end

    def time_edit value, meta
      _options(value, meta).deep_merge({
        as: :time_picker,
        input_html: {
          value: time_view(value),
          class: 'input-small',
          data: { time: time_view(value) }
        }
      })
    end

    def boolean_edit value, meta
      return _options(value, meta).deep_merge({
          as: :button_radio,
          label: 'Status',
          input_html: { required: false },
          collection: {
              approved: true,
              declined: false,
              pending: nil
          },
      }) if meta.name == 'approved'
      _options(value, meta).deep_merge({
          as: :switch,
          input_html: { required: false }
      })
    end

    def collection_for_name name

      case name
        when 'title'
          { collection: %w(Mr Mrs Ms Miss Dr Prof Sir Hon)}
        when 'contact_method'
          { collection: ["Email","SMS","Telephone","Mail", "Fax"] }
        when /.*language.*/
          { collection: {English: 'E', Afrikaans: 'A'} }
        else
          meta_for_name name
      end
    end

    def meta_for_name name
      #text, password, datetime, datetime-local, date, month, time, week, number, email, url, search, tel, and color.
      case name
        when /.*gender.*/i, /.*sex.*/i, 'attorneyname'
          {  as: :gender }
        when /.*fax.*/i
          {  as: :fax_number }
        when /.*mobile.*/i, /.*cel.*/i
          {  as: :mobile_number }
        when  /.*tel.*/i, /.*phone.*/i, 'number'
          {  as: :phone_number }
        when  /.*rate$/i, /.*percent.*/i, /variance/i
          {  as: :percentage }
        when  /.*email.*/i, /.*e_mail.*/i
          {  as: :email_address }
        when  /.*amount.*/i, /.*deposit.*/i, /.*price.*/i, /.*cost.*/i, /.*cash.*/i, /.*interest$/i, /.*payment.*/i, /.*fee.*/i, /.*debt.*/i, /.*premium.*/i
          {  as: :currency }
        else
          {}
      end

    end

    def string_edit value, meta
      merger = collection_for_name meta.name
      Rails.logger.info '-----------------------------------------------------'
      Rails.logger.info value
      Rails.logger.info meta.name
      case meta.name
        when 'acbcode', 'acbnumber'
          merger = { input_html: { pattern: ".{6}", title: 'Requires 6 characters' } }
        when  'payload'
          merger = {  as: :button_file, label: false, input_html: { data: { value: value } } }
        when 'bondIndicator', 'instruction', 'MLA'
          merger = boolean_edit value, meta
      end
      _options(value, meta).deep_merge(merger)
    end

    def decimal_edit value, meta
      string_edit value, meta
    end

    def text_edit value, meta
      string_edit value, meta
    end

    def integer_edit value, meta
      string_edit value, meta
    end

    def float_edit value, meta
      string_edit value, meta
    end

  end
end
