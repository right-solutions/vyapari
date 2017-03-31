module Vyapari
  class ApplicationController < Kuppayam::BaseController
    
    include Usman::AuthenticationHelper

    before_action :current_user
    
    def set_default_title
	    set_title("Vyapari - User Management System")
	  end

  end
end
