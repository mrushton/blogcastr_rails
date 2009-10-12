  module Authentication
    def self.included(controller) # :nodoc:
      controller.send(:include, InstanceMethods)

      controller.class_eval do
        helper_method :rest_authenticate, :rest_current_user, :signed_in_as_blogcastr_user?, :signed_in_as_facebook_user?, :signed_in_as_twitter_user?
        hide_action :rest_authenticate, :rest_current_user, :signed_in_as_blogcastr_user?, :signed_in_as_facebook_user?, :signed_in_as_twitter_user?
      end
    end

    module InstanceMethods
      #MVR - rest authentication
      def rest_authenticate
        if rest_current_user.nil?
          respond_to do |format|
            format.xml {render :xml => "<errors><error>Authentication failed</error></errors>", :status => :unprocessable_entity}
            format.json {render :json => "[[\"Authentication failed\"]]", :status => :unprocessable_entity}
          end
        end
      end

      def rest_current_user
        if @_rest_current_user.nil?
          if token = params[:authentication_token] 
            @_rest_current_user = BlogcastrUser.find_by_authentication_token(token)
          end
        end
        @_rest_current_user
      end

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
