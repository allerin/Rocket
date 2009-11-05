class DesignOrderOptionValue < ActiveRecord::Base

  def self.new_from_design_option_value( dov )
    doov = self.new
    doov.option_label = dov.design_option.label
    doov.option_customer_label = dov.design_option.customer_label
    doov.value_label = dov.label
    doov.value_customer_label = dov.customer_label
    doov.setup_price = dov.setup_price
    return doov
  end

end
