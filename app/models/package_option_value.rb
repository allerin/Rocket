#this is a join table for Packages and ProductOptionValues. when a ProductOptionValue is associated with the Package, the customer selects this value for the Package, and that value now applies for all the Package's items and their products.
class PackageOptionValue < ActiveRecord::Base
  belongs_to :package
  belongs_to :product_option_value
end
