require 'digest/sha1'

class User < ActiveRecord::Base
  belongs_to :role
  
  attr_accessor :password_confirmation
  
  allow_read( [:screen_name, :password] ){ |r| true }
  
  allow_read( :all ){ |r| r == :admin } 
  allow_write( :all ){ |r| r == :admin } 

  def self.waive_security
    Thread.current[:waive_security] = true
  end
  
  def self.waive_security?
    return Thread.current[:waive_security]
  end
    
  def self.current
    Thread.current[:user]
  end
  
  def self.current=(user)
    Thread.current[:user] = user
  end
  
  def self.current_role_title
    if self.current and self.current.role and self.current.role.title
      self.current.role.title.downcase.to_sym
    end
  end
  
  def roles
    [ role ]
  end
  
  def self.get(user)
     unless user
       return nil
     end
     User.find(:first, :conditions => ["screen_name = ?", user])
  end
  
  def full_name
    if self.first_name.to_s.strip.empty?
      return self.screen_name
    elsif self.last_name.to_s.strip.empty?
      return self.first_name
    else
      return self.first_name + " " + self.last_name
    end
  end
  
  def initials
    self.first_name.to_s[0..0].to_s + '.' + self.last_name.to_s[0..0].to_s + '.'
  end
  
  def password=(str)
    unless str.nil? || str.empty?
      password = Digest::SHA1.hexdigest( str + "nomad" )
    else
      password = str
    end
    write_attribute( "password", password )
    return str
  end
  
  def password_confirmation=(str)
    unless str.nil? || str.empty?
      password_confirmation = Digest::SHA1.hexdigest( str + "nomad" )
    else
      password_confirmation = str
    end
    write_attribute( "password_confirmation", password_confirmation )
    return str
  end
  
  def password?( str )
    chk_pass = Digest::SHA1.hexdigest( str + "nomad" )
    the_pass = self["password"]
    return chk_pass == the_pass
  end
  
  def password
    "*" * 10
  end
  
  def password_confirmation
    self["password_confirmation"]
  end
  
  def self.authenticate(signin, password)
    matches = self.find(:all, :conditions => ["screen_name = ? OR email = ?", signin, signin])
    matches.each { |user| return user.id if user.password?( password ) }
    return nil
  end
  
  def self.authenticate?(signin, password)
    user = self.authenticate(signin, pass)
    return false if user.nil?
    return true
  end
  
end
