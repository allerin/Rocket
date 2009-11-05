class Image < FlexImage::Model
  belongs_to :order
  self.file_store = "uploads/images"
  
  def self.add_to_order(order, side, upload)
    extension = File.extname(upload.original_filename)
    if extension.downcase == '.zip'
      zip_name = "image_#{Time.now.to_i}"
      zip_file = File.open("/tmp/#{zip_name}.zip", 'w+') { |f| f.write(upload.read)}
      Dir.mkdir("/tmp/#{zip_name}")
      `unzip -j -o /tmp/#{zip_name}.zip -d /tmp/#{zip_name}`
      if image_file = Dir["/tmp/#{zip_name}/*"].first
        extension = File.extname(image_file)
        filename = make_order_directory(order) + "/" + make_filename(order,side, extension)
        long_filename = RAILS_ROOT + '/' + filename
        File.open(long_filename, "w" ) { |f| f.write(File.read(image_file))}
        image = Image.new(:data => File.open(image_file), :side => side[(0..0)], :order => order, :filename => filename)
        image.save!
        order.send("#{side}_image=".to_sym, image)
        image
      end
    else 
      filename = make_order_directory(order) + "/" + make_filename(order,side, extension)
      long_filename = RAILS_ROOT + '/' + filename
      File.open(long_filename, "w" ) { |f| f.write(upload.read) }
      image = Image.new(:data => upload, :side => side[(0..0)], :order => order, :filename => filename)
      image.save!
      order.send("#{side}_image=".to_sym, image)
      image
    end
  end

  def self.make_filename(order, prefix, extension)
    if previous = Dir["#{RAILS_ROOT}/uploads/#{order.id}/#{prefix}*"].last and previous.match(/#{prefix}_\d+/)
      previous_number = previous.match(/#{prefix}_\d+/).to_s.match(/\d+/).to_s.to_i
      return prefix.to_s + "_" + (previous_number + 1).to_s + extension
    else
      return prefix.to_s + "_1" + extension
    end
  end
  
  def self.make_order_directory(order)
    Dir.mkdir("#{RAILS_ROOT}/uploads/#{order.id}" ) unless File.directory?("#{RAILS_ROOT}/uploads/#{order.id}")
    system("chmod 0777 #{RAILS_ROOT}/uploads/#{order.id}")
    return "uploads/#{order.id}"
  end  
end
