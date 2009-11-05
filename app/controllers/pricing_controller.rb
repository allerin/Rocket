class PricingController < ApplicationController
	
	def index
		@products = Product.find(:all)
		@qtys = get_qtys
	end
	
	def price
		if params[:id]
			product = Product.find(params[:id])
			qty = params[:qty] ? params[:qty] : get_qtys[1]
			
			@price_opts = {}
			if params[:product_option_value]
				params[:product_option_value].collect { |label, val| @price_opts[label.to_sym] = val }
			else
				product.options_map.each { |key, val| @price_opts[key] = val.first }
			end 
	
			@explanation = product.price_explain(qty.to_i, 1.0, @price_opts)
		end
		render(:partial =>'price')
	end
	
	def get_qtys
		steps = Quantity.find(:all, :order=>'first asc')
		qtys = Array.new
		steps.each do |qty|
			s = qty.first
			while s <= qty.last do
				qtys << s
				s += qty.step
			end
		end
		return qtys
	end
	
end
