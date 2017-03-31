module Vyapari
  module Admin
    class BaseController < ApplicationController
      
      layout 'kuppayam/admin'
      
      before_action :require_user
      
      private

      def set_default_title
        set_title("Vyapari Admin | Vyapari Stock Management Module")
      end
      
    end	
  end
end
