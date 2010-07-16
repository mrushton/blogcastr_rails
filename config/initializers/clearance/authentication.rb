module Clearance
  module Authentication
    module InstanceMethods
      protected

      #MVR - handle https redirects
      def secure_redirect_back_or(default)
        if Rails.env.production?
          url = return_to || default
          if url =~ /\//
            url = "http://blogcastr.com" + url
          end
          redirect_to url
          clear_return_to
        else
          redirect_to(return_to || default)
          clear_return_to
        end
      end

      #MVR - handle https redirects to home
      def secure_redirect_to_home
        if Rails.env.production?
          redirect_to home_url
        else
          redirect_to home_path
        end
      end
    end
  end
end
