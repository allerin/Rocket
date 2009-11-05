
module TModelSecurity
  
  autoload :Role, 'role'
  autoload :User, 'user'
  
  def self.included(model)
    model.extend(InstanceMethods)
  end
  
  
  module InstanceMethods
        
    def permissions
      @permissions or (@permissions = { })
    end
    
    def permissions=(p)
      @permissions = p
    end
  
    def write_methods
      @write_methods or ( @write_methods = Set.new )
    end
      
    def allow_read( attributes, &b )
      allow_something(:r, attributes, &b)
    end
    
    def allow_write( attributes, &b )
      allow_something(:w, attributes, &b)
    end
    
    def allow_something( permission, attributes, &b )
            
      case attributes.class.to_s
      when ('Symbol' or 'String')
        attribute = attributes.to_sym
        generate_secure_accessor_method( attribute )
        generate_secure_assignment_method( attribute )
        Role.all.each { | role | allow_for_one_attribute_and_role( permission.to_sym, attribute, role) if b[role] }
      when 'Array'
        attributes.each { | attribute | allow_something( permission, attribute, &b ) }
      end
    end
          
    def allow_for_one_attribute_and_role( permission, attribute, role )
      role = role.to_sym
  
      new_permission = { attribute => { role => [ permission.to_sym ] } }
      self.permissions = self.permissions.merge( new_permission ) { | a, old_roles, new_roles |
        old_roles.merge( new_roles ) { | r, old_perms, new_perms | ( old_perms + new_perms ).uniq }
      }
    end
  
    def generate_secure_accessor_method( attribute )
      unless attribute == :all or self.read_methods.include?(attribute)
        if self.method_defined?( attribute )
          original_accessor = self.instance_method( attribute )
          define_method( attribute ){
            return original_accessor.bind(self).call if check_permission( :r, attribute )
            raise SecurityError.new("#{User.current_role_title} is not allowed to read #{self.class}##{attribute}.")
          }
        else
          define_method( attribute ){
            return @attributes[attribute.to_s] if check_permission( :r, attribute)
            raise SecurityError.new("#{User.current_role_title} is not allowed to read #{self.class}##{attribute}.")
          }
        end
        self.read_methods.add(attribute)
      end
    end
    
    def generate_secure_assignment_method( attribute )
      unless attribute == :all or self.write_methods.include?(attribute)
        attribute_equals = (attribute.to_s + "=").to_sym
        if self.method_defined?( attribute_equals )
          original_accessor = self.instance_method( attribute_equals )
          define_method( attribute_equals ){ |value| 
            return original_accessor.bind( self  ).call( value ) if check_permission( :w, attribute )
            raise SecurityError.new("#{User.current_role_title} is not allowed to write #{self.class}##{attribute}.") }
        else
          define_method( attribute_equals ){ |value|
            return @attributes[attribute.to_s]=value if check_permission( :w, attribute)
            raise SecurityError.new("#{User.current_role_title} is not allowed to write #{self.class}##{attribute}.") }
        end
        self.write_methods.add(attribute)
      end
    end
    
    def can_read?(name)
      check_permission(:r, name)
    end
    
    def can_write?(name)
      check_permission(:w, name)
    end
    
    def check_permission(permission, name)
      return true if User.waive_security?
      
      p = permission.to_sym

      if this_method_perm = self.class.permissions[ name.to_sym ]
        if this_user_perm = this_method_perm[ User.current_role_title ]
          return true if this_user_perm.include?( p )
        end
        if all_user_perm = this_method_perm[ :all ]
          return true if all_user_perm.include? ( p )
        end
      end
      
      if all_method_perm = self.class.permissions[ :all ]
        if this_user_perm = all_method_perm[ User.current_role_title ]
          return true if this_user_perm.include?( p )
        end
        if all_user_perm = all_method_perm[ :all ]
          return true if all_user_perm.include?( p )
        end
      end
        
      return false
    end
  
    
  end #InstanceMethods
end

module TModelSecuritySupport
  
#  autoload :Role, 'role'
  autoload :User, 'user'
 

  def self.included(controller)
    controller.send :before_filter, :tmodel_assign_current_user
  end
  
  def tmodel_assign_current_user
    session[:user] ||= 0
    User.current = User.find( :first, :conditions => ["id = ?", session[:user]] )
    
    return true
  end
  
end
