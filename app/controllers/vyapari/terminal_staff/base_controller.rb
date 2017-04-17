module Vyapari
  module TerminalStaff
    class BaseController < ApplicationController
      
      layout 'vyapari/terminal_staff'
      
      before_action :require_user
      
      private

      def set_default_title
        set_title("Termianl - Point of Sale | Merchandise Application")
      end

      def get_nested_resource_objects
        @terminal = Terminal.find_by_id(params[:terminal_id])
        @store = @terminal.store if @terminal
      end

      def configure_filter_param_mapping
        @filter_param_mapping = default_filter_param_mapping
        
        # Variable Filters
        @filter_param_mapping[:store] = :st
        @filter_param_mapping[:terminal] = :tm

        # Second variable for mapping reference filters
        @filter_param_mapping[:fstore] = :fst
        @filter_param_mapping[:fterminal] = :ftm
        
        @filter_param_mapping[:supplier] = :sp
        @filter_param_mapping[:user] = :us
        @filter_param_mapping[:payment_method] = :pm
      end
      
    end	
  end
end
