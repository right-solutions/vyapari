module Vyapari
  class ApplicationController < Kuppayam::BaseController
    
    include Usman::AuthenticationHelper

    before_action :current_user
    
    def set_default_title
	    set_title("Vyapari - Merchandise Application")
	  end

	  def default_redirect_url_after_sign_in
      vyapari.user_dashboard_url
      # if @current_user.has_role?("Admin")
      #   vyapari.admin_dashboard_url
      # elsif @current_user.has_role?("Admin")
      #   vyapari.store_dashboard_url
      # else
      #   vyapari.admin_dashboard_url
      # end
    end

  end
end
