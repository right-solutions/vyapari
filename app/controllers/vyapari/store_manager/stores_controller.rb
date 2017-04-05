module Vyapari
	module StoreManager
	  class StoresController < Vyapari::StoreManager::BaseController

	  	# GET /dashboard
	    def index
	    	@stores = Store.all
	    end

	    private

	    def breadcrumbs_configuration
	      {
	        heading: "Stores",
	        description: "Browse through the stores",
	        links: [{name: "Home", link: store_manager_stores_path, icon: 'fa-shop'}]
	      }
	    end

	    def set_navs
	      set_nav("store_manager/home")
	    end

	  end
	end
end

