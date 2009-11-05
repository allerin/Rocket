class Cart
  
  attr_accessor :products, :design_jobs, :packages, :customer
  
  def initialize(customer = nil)
    @products = []
    @design_jobs = []
    @packages = []
    @customer = customer
  end
  
  def add_product(cart_product)
    @products.insert 0, cart_product
  end
    
  def remove_product(cart_index)
    @products.delete_at cart_index.to_i
    @design_jobs.each do | design |
      if design.for_cart_item and not @products.include?( design.for_cart_item )
        design.for_product_id = design.for_cart_item.product_id
        design.for_cart_item = nil
      end
    end
  end
  
  def add_design_job( design_job )
    @design_jobs.insert 0, design_job
  end
  
  def remove_design_job(design_index)
    @design_jobs.delete_at design_index.to_i
  end
  
  def add_package(package)
    @packages.insert 0, package
  end
  
  def remove_package(package_item_index)
    @packages.delete package_items[package_item_index.to_i].package
  end
  
  def length
    @products.length + @design_jobs.length + @packages.length
  end
  
  def print_total
    @products.inject(0) { | total, cart_product| total += cart_product.price } +
      @packages.inject(0) { | total, cart_package| total += cart_package.price }
  end
  
  def mailing_total
    @products.inject(0) { | total, cart_product| total += cart_product.mailing_price }
  end
  
  def postage_total
    @products.inject(0) { | total, cart_product| total += cart_product.postage_price }
  end
 
  def design_total
	  @design_jobs.inject(0) { |total, design | total += design.total_price }
	end
	
	def shipping_total
	  @products.inject(0) { | total, cart_product| total += cart_product.shipping_price } +
	    @packages.inject(0) { | total, cart_package| total += cart_package.shipping_price }
	end
	
	def tax_total
	  @products.inject(0) { |total, cart_product | total += cart_product.tax } +
	    @packages.inject(0) { | total, cart_package| total += cart_package.tax }
  end
	
	def total
	  print_total + mailing_total + design_total + shipping_total + postage_total + tax_total
	end
	
	def package_items
	  packages.collect(&:package_items).flatten
	end
	
	def apply_coupon_to_packages(coupon)
	  package_items.inject([]) do |winners, item|
      winners << item if item.apply_coupon(coupon)
      winners
    end
	end
	
	def apply_coupon_to_products(coupon)
	  products.inject([]) do |winners, item|
      winners << item if item.apply_coupon(coupon)
      winners
    end
	end

	
end