class LandingController < Vyapari::ApplicationController

	# GET /dashboard
  def index
  	#redirect_to vyapari.admin_countries_url
  	redirect_to usman.admin_dashboard_url
  end

end

