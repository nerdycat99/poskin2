# frozen_string_literal: true

module ItemsHelper
  def items_as_params(items)
    items_as_params = []
    items.map{|item| items_as_params << { variant_id: item['variant_id'], quantity: item['quantity'] } if item['variant_id'].present? && item['quantity'].present? }
    items_as_params
  end

  def add_items_to_order(order, items)
    item_array = items.split('/').map{|i| i.split('&')}
    item_array.each do |item|
      order.order_items.new(item.map{|str| str.split('=') }.to_h)
    end
    order
  end

  def remove_item_from_items(item, items)
    item_array = items.split('/')
    target = item_array.index(item)
    item_array.delete_at(target)
    item_array.join('/')
  end
end
