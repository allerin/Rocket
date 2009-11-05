module Caboose
  # The RoleHandler hold a collection of RoleLookup objects
  # one RoleLookup object gets initialized fror every role.title
  # returned from Role.find(:all). so your set up a RoleHandler
  # and give it the Role model object.
  # @handler = RoleHandler.new(Role)
  # @handler.process("(admin | moderator) & !blacklisted", @user)
  class RoleHandler
    include LogicParser
    # loads an ActiveRecord Role model and registers all the roles.
    def initialize(model)
      @acls = {}
      model.find(:all).each do |role|
        register_role(role.title)
      end
    end
    
    # Registers a role by title
    def register_role(role)
      role.downcase!
      if @acls.has_key? role
        raise DuplicateRoleError, "An Role named '#{role}' is already registered"
      end
      @acls[role] = RoleLookup.new(role)
    end
    
  end # End RoleHandler
  
  # Does a check using an active record lookup on a role model
  class RoleLookup
     # role gets passed in here. 
     def initialize(role)
        @role = role
     end
     # Check gets called with context. context has a user model object
     # in context[:user]. We collect all the user.roles title attribute
     # and see if @role is included in those role.title's
     def check(user)
        user.roles.map{|role| role.title.downcase}.include? @role
     end
   end # END RoleLookup
   
   # raised when two Role's of the same name are registered
   class DuplicateRoleError < StandardError
   end
   
end