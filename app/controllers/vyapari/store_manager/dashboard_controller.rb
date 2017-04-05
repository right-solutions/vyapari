module Vyapari
	module StoreManager
	  class DashboardController < Vyapari::StoreManager::BaseController

	  	# GET /dashboard
	    def index
	    	@terminals = @store.terminals
	    end

	    private

	    def breadcrumbs_configuration
	      {
	        heading: "#{@store.name}",
	        description: "A Quick view of stock & sales",
	        links: [
	        	{name: "Home", link: store_manager_stores_path, icon: 'fa-building-o'},
	        	{name: @store.name, link: store_manager_dashboard_path(@store), icon: 'fa-dashboard'}
	        ]
	      }
	    end

	    def set_navs
	      set_nav("store_manager/stocks")
	    end

	  end
	end
end

