module Vyapari
  module TerminalStaff
    class BaseController < ApplicationController
      
      layout 'vyapari/terminal_staff'
      
      before_action :require_user
      
      private

      def set_default_title
        set_title("Vyapari Store | Vyapari Stock Management Module")
      end

      def get_nested_resource_objects
        @terminal = Terminal.find_by_id(params[:terminal_id])
        @store = @terminal.store if @terminal
      end

      def configure_filter_param_mapping
        @filter_param_mapping = default_filter_param_mapping
        @filter_param_mapping[:terminal] = :tm
        @filter_param_mapping[:store] = :st
        @filter_param_mapping[:supplier] = :sp
      end
      
    end	
  end
end
