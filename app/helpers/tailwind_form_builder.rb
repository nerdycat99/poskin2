# frozen_string_literal: true

class TailwindFormBuilder < ActionView::Helpers::FormBuilder
  include ApplicationHelper
  include ERB::Util

  delegate :tag, :safe_join, to: :@template

  def text_field(method, opts = {})
    default_opts = { class: 'mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-300 focus:ring focus:ring-indigo-200 focus:ring-opacity-50' }
    merged_opts = default_opts.merge(opts)
    super(method, merged_opts)
  end

  def input(method, options = {})
    @form_options = options
    object_type = object_type_for_method(method)

    input_type = case object_type
                 when :date then :string
                 when :integer then :string
                 else object_type
                 end

    override_input_type = if options[:as]
                            options[:as]
                          elsif options[:collection]
                            :select
                          end

    send("#{override_input_type || input_type}_input", method, options)
  end

  def labelled_date(label, attr_name, min_date, max_date, options = {})
    classes = extract_classes(options)
    min = min_date.to_date.iso8601
    max = max_date.to_date.iso8601
    div_id = "datepicker_#{rand(1000000)}"
    field_data = options.delete(:field_data)
    view_mode = (options[:data] && options[:data].delete("view-mode")) || (options.delete("data-view-mode")) || "months"
    options.delete(:data) if (options[:data] && options[:data].empty?)

    if label.nil?
      label_div = ""
    else
      label_div = @template.content_tag(:div, class: "label") {
        @template.label_tag(attr_name, html_escape(label), class: "#{options.delete(:label_class)} col-form-label") + tooltip_icon(options.delete(:tooltip))
      }
    end

    display_placeholder = options['data-format'].nil? ? "#{options.delete(:placeholder) || label} (dd/mm/yyyy)" : "#{options.delete(:placeholder) || label} (#{options['data-format'].downcase})"


    value = self.object.try(attr_name)
    if value.presence.respond_to?(:to_date)
      date_val = value.to_date
      if date_val < min_date.to_date
        min = date_val.iso8601
      end
      if max_date.to_date < date_val
        max = date_val.iso8601
      end
    end

    tag_options = {
      object: self.object,
      min: min,
      max: max,
      placeholder: display_placeholder,
      class: "#{options.delete(:input_class)} form-control",
      data: {target: "##{div_id}", toggle: "datetimepicker"}
    }.merge(options)

    field = ActionView::Helpers::Tags::TextField.new(self.object_name, attr_name, @template, tag_options)

    rendered_field = @template.content_tag(:div, {"id"=>div_id, "class"=>"#{options.delete(:input_class)} input-group date", "data-target-input"=>"nearest", "data-view-mode"=>view_mode}.merge(options)) {[
      field.render.html_safe,
      label_div,
      @template.content_tag(:div, class: "input-group-append", data: {target: "##{div_id}", toggle: "datetimepicker"}) {
        @template.content_tag(:div, class: "input-group-text") {
          @template.content_tag(:i, nil, class: "mdi mdi-calendar")
        }
      }
    ].join.html_safe}

    # field.object > is the report model and att_name is an attribute in the report

    if field.object && (error = field.object.errors[attr_name].presence)
      classes[:field] << "field_with_errors"
      error_field = @template.content_tag(:div, "#{label} #{error.to_sentence}", class: "error")
      rendered_field = rendered_field + error_field
    end

    @template.content_tag(:div, class: classes[:field].join(' '), data: field_data) {
      @template.content_tag(:div, rendered_field, class: 'form-group form-row with-floating-label')
    }.html_safe
  end

  def submit_button(text, opts: {})
    classes = (opts.delete(:class) || opts.delete('class') || '').split
    classes << 'btn btn-primary'
    # classes << "btn-primary" unless classes.any?{|c| c =~ /^btn-/}
    @template.button_tag(text, opts.merge(class: classes.uniq.join(' ')))
  end

  private

  def form_group(method, options = {}, &block)
    tag.div class: "form-group #{method}" do
      safe_join [
        block.call,
        hint_text(options[:hint]),
        error_text(method)
      ].compact
    end
  end

  def collection_input(method, options, &block)
    form_group(method, options) do
      safe_join [
        label(method, options[:label]),
        block.call
      ]
    end
  end

  def has_error?(method)
    return false unless @object.respond_to?(:errors)

    @object.errors.key?(method)
  end

  def hint_text(text)
    return if text.nil?

    tag.small text, class: 'form-text text-muted'
  end

  def error_text(method)
    return unless has_error?(method)

    tag.div(@object.errors[method].join('<br />').html_safe, class: 'invalid-feedback')
  end

  def select_input(method, options = {})
    value_method = options[:value_method] || :to_s
    text_method = options[:text_method] || :to_s
    input_options = options[:input_html] || {}

    multiple = input_options[:multiple]

    collection_input(method, options) do
      collection_select(method, options[:collection], value_method, text_method, options, merge_input_options({ class: "#{unless multiple
                                                                                                                            'custom-select'
                                                                                                                          end} form-control #{if has_error?(method)
                                                                                                                                                'is-invalid'
                                                                                                                                              end}" }, options[:input_html]))
    end
  end

  def object_type_for_method(method)
    result = if @object.respond_to?(:type_for_attribute) && @object.has_attribute?(method)
               @object.type_for_attribute(method.to_s).try(:type)
             elsif @object.respond_to?(:column_for_attribute) && @object.has_attribute?(method)
               @object.column_for_attribute(method).try(:type)
             end

    result || :string
  end

  def merge_input_options(options, user_options)
    return options if user_options.nil?

    # TODO: handle class merging here
    options.merge(user_options)
  end
end
