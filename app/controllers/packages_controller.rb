class PackagesController < ApplicationController
  layout 'customer'
  
  def intro
    render :template => "packages/intros/" + params[:page]
  end
  
  def show
    @package = CartPackage.new(@cart, Package.find_by_shortname(params[:shortname]))
  end

  def calculate_price
    @package = CartPackage.new(@cart, Package.find_by_shortname(params[:shortname]))
    for item in @package.package_items do
      if item_params = params[:items][item.id.to_s]
        if param_options = item_params[:options]
          item.product_options.each do | option |
            item.option_values[option] = ProductOptionValue.find(param_options[option.id.to_s]) if param_options[option.id.to_s]
          end
        end
        item.quantity = item_params[:quantity].to_i if item_params[:quantity]
        item.versions = item_params[:versions].to_i if item_params[:versions]
      end
    end 
    if package_options = params[:package_options]
      @package.product_options.each do | option |
        @package.option_values[option] = ProductOptionValue.find(package_options[option.id.to_s]) if package_options[option.id.to_s]
      end
    end   
    #logger.debug @package.package_items.first.option_values.to_yaml
    # I have make comment this one. Just for checking.
    render :update => true, :layout => false do | page |
    page['package_items'].update render(:partial => 'items')
      #render :update => true, :layout => false do | page |
      #page['package_items'].update(render(:partial => 'items'))
    end
  end

end
