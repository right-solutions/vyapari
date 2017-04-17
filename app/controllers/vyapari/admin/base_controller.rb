module Vyapari
  module Admin
    class BaseController < ApplicationController
      
      layout 'kuppayam/admin'
      
      before_action :require_user
      before_action :require_site_admin
      
      private

      def set_default_title
        set_title("Dashboard | Admin")
      end

      def require_site_admin
        unless @current_user.has_role?("Site Admin")
          text = "#{I18n.t("authentication.permission_denied.heading")}: #{I18n.t("authentication.permission_denied.message")}"
          set_flash_message(text, :error, false) if defined?(flash) && flash
          redirect_to default_redirect_url_after_sign_in
        end
      end
      
    end	
  end
end
