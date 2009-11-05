class UploadController < ApplicationController
  include CustomerSigninSystem
  layout 'customer'
  #before_filter :signin_required, :only => [ :index, :send_email ]
  session :off, :only => [:progress]
  
  # Open iBox
  def aa
    @order = Order.find(params[:id])
    render :partial => "checkout/aa"
  end
  
  def index
    @orders = params[:orders] && params[:orders].split(',').collect(&:strip).collect { |job| Order.find_by_full_job_number(job) }.compact
  end
  
  def refresh
    order = Order.find(params[:order_id])
    
    order.art_upload_method = params[:art_upload_method] if params[:art_upload_method]
    order.list_upload_method = params[:list_upload_method] if params[:list_upload_method]
    
    order.save
    
    render(:update => true, :layout => false) do |page|
      page["order_#{order.id}"].update( render(:partial => 'customer_upload_order', :locals => { :order => order }) )
    end
  end
  
  def refresh1
    order = Order.find(params[:order_id])
    
    order.art_upload_method = params[:art_upload_method] if params[:art_upload_method]
    order.list_upload_method = params[:list_upload_method] if params[:list_upload_method]
    
    order.save
    
    render(:update => true, :layout => false) do |page|
      page["order_#{order.id}"].update( render(:partial => 'customer_upload_order1', :locals => { :order => order }) )
    end
  end
  
  def send_email
    order = Order.find(params[:order_id])
    
    if params[:email] == params[:email_confirm] and not params[:email].nil? and not params[:email].empty?
      CustomerMail.deliver_upload_instructions( params[:email], order, designer_upload_url(:order_id => order.id))
      flash.now[:email] = params[:email]
    end
    
    redirect_to :action => 'order_summary', :id => order.id, :name => 'email'
  end
  
  def upload
    @order = Order.find(params[:order_id])
    finish_types = []
    
    ['front', 'back', 'list'].each do |type|
      if params[type].kind_of?( Tempfile )
        if type == 'list'
          List.add_to_order(@order, params[type])
        else
          image = Image.add_to_order(@order, type, params[type])
        end
        mark_as_received(type)
        finish_types << type
        @order.save
      end
    end
    
    render :text => %(
    <script type="text/javascript">) +
    finish_types.collect { |t| "window.parent.UploadProgress.finish(#{@order.id}, '#{t}'); " }.join +
    %(</script>)
  end
  
  def finished
    @order = Order.find(params[:order_id])
    
    render :update => true, :layout => false do |page|
      if params[:type] == 'list'
        page["upload_list_#{@order.id}"].update(render(:partial => ("upload/list/" + @order.list_upload_method),
        :locals => { :order => @order }))
      elsif @order.art_upload_method
        page["upload_#{@order.id}"].update(render(:partial => ("upload/art/" + @order.art_upload_method),
        :locals => { :order => @order }))
      end
    end
  end
  
  def show
    @order = Order.find(params[:order_id])
    render :update => true, :layout => false do |page|
      page << %Q{ new Effect.ScrollTo("order_#{@order.id}", { offset: -16, queue: "end", afterFinish: function() {  }}); }
      page["order_#{@order.id}"].update(render(:partial => 'customer_upload_order', :locals => { :order => @order }))
    end
  end
  
  
  def mark_as_received(type)
    case type
    when 'front'
      @order.front_art_received = true
    when 'back'
      @order.back_art_received = true
    when 'list'
      @order.mailing_list_received = true
    end
  end
  
  
  def designer
    @orders = Order.find(params[:order_id]).invoice.orders.find(:all, :conditions => "art_upload_method='email' OR list_upload_method='email'")
  end
  
  def progress
    render :update => true, :layout => false do |page|
      @status = Mongrel::Uploads.check(params[:upload_id])
      logger.debug "\n\n\n\n\nstatus: #{@status.to_yaml} \n\n\n"
      page.upload_progress.update(@status[:size], @status[:received]) if @status
    end
  end
  
#  def upload1
#    @order = Order.find(params[:order_id])
#    
#    pictures = []
#    params[:uploaded_data].each do |file|
#      pictures << @picture = Picture.new({:uploaded_data => file})
#    end     
#    Picture.transaction { pictures.each &:save! }
#    redirect_to :action => 'order_summary', :id => @order.id
#  end
  
  def upload2
    @order_id=params[:order_id]
    @order = Order.find(params[:order_id])
    @invoice_id= @order.invoice_id.to_s
    if(params[:upload1][:datafile1] == nil || params[:upload1][:datafile1].length == 0)
    else
      post = Picture.upload1(params[:upload1],@invoice_id,params[:upload1][:datafile1],1.to_s)
      post = Picture.new
      post.order_id=@order_id
      post.filename=params[:upload1][:datafile1].original_filename
      post.save
    end
    if(params[:upload2][:datafile2] == nil || params[:upload2][:datafile2].length == 0)
    else
      post = Picture.upload1(params[:upload2],@invoice_id,params[:upload2][:datafile2],2.to_s)
      post = Picture.new
      post.order_id=@order_id
      post.filename=params[:upload2][:datafile2].original_filename
      post.save
    end
    
    redirect_to :action => 'order_summary', :id => @order_id
  end
  
  # Added by SUHAS, Currently this 'upload3' method is used to upload Artworks.
  def upload3
    @order_id=params[:order_id]
    @order = Order.find(params[:order_id])
    @invoice_id= @order.invoice_id.to_s
    if(params[:upload1][:datafile1] == nil || params[:upload1][:datafile1].length == 0)
    else        
      post = Picture.upload1(params[:upload1],@invoice_id,params[:upload1][:datafile1],1.to_s)
      post = Picture.new
      post.order_id=@order_id
      post.filename=params[:upload1][:datafile1].original_filename
      post.save
    end
    if(params[:upload2][:datafile2] == nil || params[:upload2][:datafile2].length == 0)
    else
      post = Picture.upload1(params[:upload2],@invoice_id,params[:upload2][:datafile2],2.to_s)
      post = Picture.new
      post.order_id=@order_id
      post.filename=params[:upload2][:datafile2].original_filename
      post.save
    end
    
    #redirect_to :action => 'order_summary', :id => @order_id
    responds_to_parent do
      render :update do |page|
        page << "hideIbox();"
        page.replace_html "order11_#{@order.id}", :partial => 'tt'
        page.replace_html "proceed", :partial => 'proceedpage'
      end
    end
  end
  
  def drop_mail_artwork
    @order = Order.find(params[:order_id])
    responds_to_parent do
      render :update do |page|
        page << "hideIbox();"
        page.replace_html "order11_#{@order.id}", "I will mail Artwork."
        page.replace_html "proceed", :partial => 'proceedpage'
      end
    end
  end
  
  def drop_off_artwork
    @order = Order.find(params[:order_id])
    responds_to_parent do
      render :update do |page|
        page << "hideIbox();"
        page.replace_html "order11_#{@order.id}", "I will drop off Artwork."
        page.replace_html "proceed", :partial => 'proceedpage'
      end
    end    
  end
  
  def order_summary
    @order = Order.find(params[:id])
    if params[:name] == 'drop'
      @name = 'drop'
    elsif params[:name] == 'email'
      @name = 'email'
    end
  end
  
  
end
