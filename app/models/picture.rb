class Picture < ActiveRecord::Base

  has_attachment :content_type => :image, 
                 :storage => :file_system, 
                 :max_size => 5000.kilobytes,
                 :resize_to => '320x200>',
                 :thumbnails => { :thumb => '60x80>' },
                 :processor => :rmagick  

  #validates_as_attachment
  
    def self.upload1(upload,id,file_history,type)
        name =  file_history.original_filename
        directory =  FileUtils.mkdir_p 'uploads/'+('R'+id+'-' +type)
        path = File.join(directory, name)
        File.open(path, "wb") { |f| f.write(file_history.read) }
    end

end
