require 'test/unit'
require File.dirname(__FILE__) + '/test_helper'
require 'ostruct'

# mock objects

class User
  def roles
    [OpenStruct.new(:title => 'admin'), OpenStruct.new(:title => 'user')]
  end  
end    

class Role
  def self.find(*args)
    [OpenStruct.new(:title => 'admin'), 
     OpenStruct.new(:title => 'moderator'),
     OpenStruct.new(:title => 'user'),
     OpenStruct.new(:title => 'anon'),
     OpenStruct.new(:title => 'blacklist')]
  end
end    

# tests         
class AccessControlTest  < Test::Unit::TestCase
  

  def test_first
    @user = User.new
    @handler = Caboose::RoleHandler.new(Role)
    assert @handler.process("(admin | moderator) & !blacklist", @user)  
    assert @handler.process("(user | moderator) & !blacklist", @user)  
    assert @handler.process("(user | moderator | user) & !blacklist", @user)  
    assert @handler.process("(user | moderator | !blacklist)", @user)  
    assert @handler.process("user & !blacklist", @user)  
    assert @handler.process("!moderator & !blacklist", @user)  
    assert @handler.process("admin & user & !blacklist", @user)  
    assert_equal @handler.process("moderator | blacklist", @user), false 
    assert_equal @handler.process("!admin | blacklist", @user), false 
    assert_equal @handler.process("moderator", @user), false 
    assert_equal @handler.process("!anon & !moderator", @user), true 
  end
  
end  