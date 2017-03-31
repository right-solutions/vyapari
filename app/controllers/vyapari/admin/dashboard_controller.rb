module Vyapari
	module Admin
	  class DashboardController < Vyapari::Admin::BaseController

	  	# GET /dashboard
	    def index
	    end

	    private

	    def breadcrumbs_configuration
	      {
	        heading: "Stock Dashboard",
	        description: "A Quick view of stocks",
	        links: [{name: "Dashboard", link: admin_dashboard_path, icon: 'fa-dashboard'}]
	      }
	    end

	    def set_navs
	      set_nav("admin/dashboard")
	    end

	  end
	end
end

