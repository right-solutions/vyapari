module Vyapari
	module TerminalStaff
	  class ResourceController < Vyapari::TerminalStaff::BaseController

	  	include ResourceHelper

	    before_action :configure_resource_controller

	    private

	    def resource_url(obj)
		    url_for([:terminal, obj.stock, obj])
		  end

	  end
	end
end
