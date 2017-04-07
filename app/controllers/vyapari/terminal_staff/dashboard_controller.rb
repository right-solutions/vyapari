module Vyapari
	module TerminalStaff
	  class DashboardController < Vyapari::TerminalStaff::BaseController

	  	# GET /dashboard
	    def index
	    end

	    def search
	    	@query = params[:query]
	    	@products = Product.search(@query).page(@current_page).per(50)
	    end

	    private

	    def breadcrumbs_configuration
	      {
	        heading: "#{@terminal.name}",
	        description: "#{@store.name}",
	        links: [
	        	{name: "Home", link: user_dashboard_path, icon: 'fa-building-o'},
	        	{name: @terminal.name, link: terminal_staff_dashboard_path(@store), icon: 'fa-desktop'}
	        ]
	      }
	    end

	    def set_navs
        set_nav("terminal_staff/dashboard")
      end

	  end
	end
end

