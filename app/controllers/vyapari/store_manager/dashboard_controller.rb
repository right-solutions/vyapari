module Vyapari
	module StoreManager
	  class DashboardController < Vyapari::StoreManager::BaseController

	  	# GET /dashboard
	    def index
	    	@date = params[:date] ? Date.parse(params[:date]) : Date.today
	    	@terminals = @store.terminals
	    end

	    private

	    def breadcrumbs_configuration
	      {
	        heading: "#{@store.name}",
	        description: "A Quick view of stock & sales",
	        links: [
	        	{name: "Home", link: user_dashboard_path, icon: 'fa-dashboard'},
	        	{name: @store.name, link: store_manager_dashboard_path(@store), icon: 'fa-dashboard'}
	        ]
	      }
	    end

	    def set_navs
	      set_nav("store_manager/dashboard")
	    end

	  end
	end
end

