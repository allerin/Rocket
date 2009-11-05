require 'tmodel_security'

ActiveRecord::Base.send :include, TModelSecurity
ActiveRecord::Base.send :include, TModelSecurity::InstanceMethods

ActionController::Base.send :include, TModelSecuritySupport
