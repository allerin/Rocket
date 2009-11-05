class OrderProductOptionValue < ActiveRecord::Base

  def self.new_from_product_option_value(pov)
    opov = self.new
    opov.title = pov.product_option.title
    opov.setup_price = pov.product_option.setup_price
    opov.label = pov.label
    opov.kind = pov.kind
    opov.price_per_unit = pov.price_per_unit
    opov.unit_quantity = pov.unit_quantity
    opov.price_per_sqin = pov.price_per_sqin
    opov.price_rule = pov.price_rule
    opov.customer_label = pov.customer_label
    opov.never_visible = pov.product_option.never_visible
    opov.turnaround_offset = pov.turnaround_offset
    return opov
  end

  def product_option
    @product_option ||= ProductOption.find_by_title(self.title)
  end
end
