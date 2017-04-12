module Vyapari
  module StoreManager
    class BaseController < ApplicationController
      
      layout 'vyapari/store_manager'
      
      before_action :require_user
      
      private

      def set_default_title
        set_title("Vyapari Store | Vyapari Stock Management Module")
      end

      def get_nested_resource_objects
        @store = Store.find_by_id(params[:store_id])
      end

      def configure_filter_param_mapping
        @filter_param_mapping = default_filter_param_mapping
        @filter_param_mapping[:stock_bundle] = :sb
        @filter_param_mapping[:store] = :st
        @filter_param_mapping[:supplier] = :sp
        @filter_param_mapping[:brand] = :br
        @filter_param_mapping[:category] = :ct
        @filter_param_mapping[:payment_method] = :pym
        @filter_param_mapping[:terminal] = :trm
        @filter_param_mapping[:user] = :usr
      end
      
    end	
  end
end
