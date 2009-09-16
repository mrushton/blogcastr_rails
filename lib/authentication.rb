  module Authentication
    def self.included(controller) # :nodoc:
      controller.send(:include, InstanceMethods)

      controller.class_eval do
        helper_method :signed_in_as_blogcastr_user?, :signed_in_as_facebook_user?, :signed_in_as_twitter_user?
        hide_action :signed_in_as_blogcastr_user?, :signed_in_as_facebook_user?, :signed_in_as_twitter_user?
      end
    end

    module InstanceMethods
      #MVR - this contains mostly convenience and helper methods for working with our authentication system
      def signed_in_as_blogcastr_user?
        !current_user.nil? && current_user.instance_of?(BlogcastrUser) 
      end
  
      def signed_in_as_facebook_user?
        !current_user.nil? && current_user.instance_of?(FacebookUser) 
      end

      def signed_in_as_twitter_user?
        !current_user.nil? && current_user.instance_of?(TwitterUser) 
      end
    end
  end
