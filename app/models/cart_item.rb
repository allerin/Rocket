class CartItem
  include CartPayable
  
  attr_accessor :custom_name, :shipping_method_id, :cart, :payment_method, :customer
  attr_reader :soft_options, :shipping_address_id, :payment, :coupon
  
  def initialize( parent_cart )
    @soft_options = {}
    @custom_name = nil
    @shipping_address_id = nil
    @shipping_address = nil
    @shipping_method_id = nil
    @payment_method = nil
    @customer = nil
    @cart= parent_cart
    @coupon = nil
  end
  
  def shipping_address
    if @shipping_address and @shipping_address_id and @shipping_address.id == @shipping_address_id
      return @shipping_address
    elsif @shipping_address_id
      return @shipping_address = Address.find( :first, :conditions => ["id = ?", @shipping_address_id])
    end
    return nil
  end
  
  def shipping_address=(sa)
    @shipping_address = sa
    @shipping_address_id = sa.id
  end
  
  def shipping_address_id=(said)
    if said.nil?
      @shipping_address_id = @shipping_address = nil
    else
      @shipping_address_id = said
    end
  end
  
  def soft_options=(so)
    if so.kind_of? Hash
      @soft_options = so
    else
      @soft_options = {}
    end
  end
  
end