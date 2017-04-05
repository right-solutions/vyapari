module Vyapari
  class UserDashboardController < Vyapari::ApplicationController

  	layout 'kuppayam/blank'
      
    before_action :require_user

  	def index
    end

    private

    def set_default_title
    	set_title("Dashboard")
    end

    def breadcrumbs_configuration
	      {
	        heading: current_user.display_name,
	        description: current_user.designation,
	        links: [{name: "Home", link: user_dashboard_path, icon: 'fa-dashboard'}]
	      }
	    end

	    def set_navs
	      set_nav("user/dashboard")
	    end

  end
end

