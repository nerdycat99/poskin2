# frozen_string_literal: true

module ApplicationHelper
  include ItemsHelper

  def unique_sku
    candidate_sku = (SecureRandom.random_number(9e5) + 1e5).to_i
    unique_sku if [product_sku_codes, variant_sku_codes].flatten.compact_blank.include?(candidate_sku)
    candidate_sku
  end

  def product_sku_codes
    Product.all.map(&:sku_code)
  end

  def variant_sku_codes
    Variant.all.map(&:sku_code)
  end

  def extract_classes(options = {})
    classes = {field: [], label: [], input: []}
    if options[:class].present?
      classes[:field] << options.delete(:class)
    end

    return classes if options.delete(:auto_width)
    parent_widths = options.delete(:parent_widths) || {}
    field_factor = options.delete(:field_factor) || 1.0
    field_widths = [12, 6, 4, 4, 3]

    parent_fraction = 1.0
    [:xs, :sm, :md, :lg, :xl].each.with_index do |sz,i|
      prefix = (sz == :xs) ? "col" : "col-#{sz}"
      if parent_widths[sz].present?
        parent_fraction = parent_widths[sz].to_f / 12.0
      end
      field_size = [field_widths[i].to_f * field_factor.to_f / parent_fraction, 12.0].min
      classes[:field] << "#{prefix}-#{field_size.round.to_i}"
    end

    classes
  end

  def tooltip_icon(tooltip)
    if tooltip.present?
      content_tag(:i, nil, class: "mdi mdi-information-outline", title: html_escape(tooltip))
    end
  end

  def convert_to_users_timezone(datetime)
    zone = ActiveSupport::TimeZone.new('Australia/Sydney')
    datetime.in_time_zone(zone)
  end

  def date_formatter(date, format = '%Y-%m-%d')
    date.strftime(format)
  end
end
