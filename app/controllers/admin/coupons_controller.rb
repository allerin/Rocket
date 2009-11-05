class Admin::CouponsController < Admin::AdminController
  layout 'main'
  before_filter :signin_required
  before_filter :find_coupon, :only => [:edit, :save, :remove]
  
  def list
    @coupons = Coupon.find(:all)
  end
  
  def edit

  end
  
  def save
    @coupon.update_attributes(params[:coupon])
    
    params[:new_products].each do |product_id|
      next if product_id.empty?
      @coupon.add_product(Product.find(product_id))
    end
    
    @coupon.save
    
    respond_to do |format|
      format.html { redirect_to admin_edit_coupon_url(:id => @coupon) }
      format.js { render(:layout => false, :update => true) { |page| page.redirect_to admin_edit_coupon_url(@coupon) }}
    end
  end
  
  def remove
    @coupon.destroy 
    
    respond_to do |format|
      format.js { render(:layout => false, :update => true) { |page| page.redirect_to admin_list_coupons_url }}
    end
  end

  def remove_assignment
    @assignment = CouponAssignment.find(params[:id])
    @assignment.destroy

    respond_to do |format|
      format.js { render(:layout => false, :update => true) { |page| page.redirect_to admin_edit_coupon_url(@assignment.coupon) }}
    end   
    
  end
  
  private 
  
  def find_coupon
    @coupon = (params[:id] ? Coupon.find(params[:id]) : Coupon.new)
  end
end
