class Admin::PackagesController < Admin::AdminController

  layout 'main'
  
  before_filter :signin_required
  
  def list
    @packages = Package.find(:all)
  end
  
  def edit
    @package = Package.find(params[:package_id]) rescue Package.new
    @products = Product.find(:all)
    @product_options = @package.product_options
    
  end

  def save
    @products = Product.find(:all)
    @package = Package.find(params[:package_id]) rescue Package.new
    @package.title = params[:package][:title]
    @package.title_image = params[:package][:title_image]
    @package.shortname = params[:package][:shortname]
    @package.subtitle = params[:package][:subtitle]
    
    if params[:package_items]
      @package.package_items.clear
      params[:package_items].each do |id, values|
        item = PackageItem.find(id) rescue PackageItem.new
        item.product_id = values[:product_id]
        item.default_quantity = values[:default_quantity]
        item.max_versions = values[:max_versions]
        item.custom_name = values[:custom_name]
        item.min_quantity = values[:min_quantity]
        item.max_quantity = values[:max_quantity]
        item.version_surcharge = values[:version_surcharge]
        
        if values[:option_values]
          item.package_item_option_values.clear
          values[:option_values].each do |pov_id, checked|
            package_item_option_value = PackageItemOptionValue.new(:product_option_value_id => pov_id)
            package_item_option_value.default = true if values[:defaults] and
              values[:defaults][package_item_option_value.product_option_value.product_option.id.to_s] == pov_id 
            item.package_item_option_values << package_item_option_value
          end
        end
        
        item.save
        @package.package_items << item
      end
    end
    
    @package.package_option_values.clear
    if params[:package_option_values]
      params[:package_option_values].each do |product_option_value_id, checked|
        if checked.to_i == 1
          package_option_value = PackageOptionValue.new(:product_option_value_id => product_option_value_id)
          package_option_value.default = true if 
            params[ :package_option_value_defaults ][ 
                    package_option_value.product_option_value.product_option_id.to_s ] == package_option_value.product_option_value.id.to_s
          @package.package_option_values << package_option_value
        end  
      end
    end
    
    @package.save 
    
    render :update => true, :layout => false do | page |
      page.redirect_to admin_edit_package_url(:package_id => @package.id)
    end
  end

  def add_product
    @package = Package.find(params[:package_id]) rescue Package.new
    @products = Product.find(:all)
    
    @package.package_items << PackageItem.new
    
    render :update => true, :layout => false do | page |
      page['package_items'].update render(:partial => 'package_items')
    end
  end
  
  def remove_product
    @package = Package.find(params[:package_id]) rescue Package.new
    @removed_item = PackageItem.find(params[:package_item_id])
    @products = Product.find(:all)
    
    @package.package_items.delete(@removed_item)
    
    render :update => true, :layout => false do | page |
      page['package_items'].update render(:partial => 'package_items')
    end
  end
  
  def add_option
    @package = Package.find(params[:package_id]) rescue Package.new
    @product_options = @package.product_options
    
    @product_options << ProductOption.find(params[:new_package_option]) if params[:new_package_option]
    
    render :update => true, :layout => false do | page |
      page['package_option_values'].update render(:partial => 'package_option_values')
    end
  end
  
  def add_item_option
    @products = Product.find(:all)
    @item  = PackageItem.find(params[:item_id])
    @package = @item.package
    @option = ProductOption.find(params[:package_items][@item.id.to_s][:new_option])
    
    @option.product_option_values.each { |pov| 
      @item.package_item_option_values << PackageItemOptionValue.new(:package_item_id => @item.id, :product_option_value_id => pov.id) }
    
    render :update => true, :layout => false do |page|
      page['package_items'].update render(:partial => 'package_items')
    end
  end
  
  def remove
    @package = Package.find(params[:package_id])
    @package.destroy
    
    redirect_to admin_list_packages_url
  end
  
end
