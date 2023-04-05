# frozen_string_literal: true

class ProductAttributeType < ApplicationRecord
  validates :name, presence: true

  before_save :parameterize_name
  after_create :blank_product_attribute_for_type

  validate :unique_attribute_type?

  def unique_attribute_type?
    return unless ProductAttributeType.find_by(name: parameterize_name)

    errors.add :name, message: '- a Product Attribute Type with this name already exists.'
    false
  end

  def parameterize_name
    self.name = name.parameterize(separator: '_')
  end

  def blank_product_attribute_for_type
    ProductAttribute.create(name: parameterize_name, value: '')
  end

  def attributes_for_type
    @attributes_for_type ||= ProductAttribute.where(name:)
  end

  def in_use?
    attributes_for_type.map(&:in_use?).any?
  end

  def remove!
    return false if in_use?

    ProductAttributeType.transaction do
      delete
      attributes_for_type.delete_all
    end
  rescue StandardError
    false
  end
end
