module Vyapari
	module StoreManager
	  class ResourceController < Vyapari::StoreManager::BaseController

	  	include ResourceHelper

	    before_action :configure_resource_controller, :set_navs

	    private

	    def resource_url(obj)
		    url_for([:store_manager, obj.stock, obj])
		  end

	  end
	end
end
