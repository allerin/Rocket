
module Caboose

  module AccessControl
    
    def self.included(controller)
      controller.extend(ClassMethods)
      controller.helper_method(:permit?)
    end

    module ClassMethods
      #  access_control [:create, :edit] => 'admin & !blacklist',
      #                 :update => '(admin | moderator) & !blacklist',
      #                 :list => '(admin | moderator | user) & !blacklist'
      def access_control(actions={})
        # Add class-wide permission callback to before_filter
        before_filter do |c|
          @access = AccessSentry.new(actions)
          unless @access.allowed?(c.action_name, c.send(:current_user))
            c.send(:render_text, "You have insufficent permissions to access #{c.controller_name}/#{c.action_name}")
          end  
        end
      end 
      
    end  

   def permit?(logicstring, user)
     @handler = RoleHandler.new(Role)
     @handler.process(logicstring, user)
   end
  
  
  class AccessSentry
    
    def initialize(actions={})
      @actions = actions.inject({}) { |auth, current|
        [current.first].flatten.each { |action| auth[action] = current.last }
        auth
        } 
      @handler = RoleHandler.new(Role)
    end 
    
    def allowed?(action, user)
      if @actions.has_key? action.to_sym
        return @handler.process(@actions[action.to_sym], user)
      else
        return true
      end  
    end

  end
  
  end #AccessControl  
  
end # Caboose    





