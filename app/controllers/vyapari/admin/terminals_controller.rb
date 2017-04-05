module Vyapari
  module Admin
    class TerminalsController < ResourceController

      before_action :get_store
      
      def index
        get_collections
        respond_to do |format|
          format.html {}
          format.js  { 
            js_view_path = @resource_options && @resource_options[:js_view_path] ? "#{@resource_options[:js_view_path]}/index" : :index 
            render js_view_path
          }
        end
      end

      def show
        @terminal = @r_object = @resource_options[:class].find_by_id(params[:id])
        set_notification(false, I18n.t('status.error'), I18n.t('status.not_found', item: default_item_name.titleize)) unless @r_object
        render_accordingly
      end

      def new
        @terminal = @r_object = @resource_options[:class].new(store: @store)
        render_accordingly
      end

      def edit
        @terminal = @r_object = @resource_options[:class].find_by_id(params[:id])
        set_notification(false, I18n.t('status.error'), I18n.t('status.not_found', item: default_item_name.titleize)) unless @r_object
        render_accordingly
      end

      def create
        @terminal = @r_object = @resource_options[:class].new(store: @store)
        @r_object.assign_attributes(permitted_params)
        save_resource
      end

      def update
        @terminal =@r_object = @resource_options[:class].find_by_id(params[:id])
        if @r_object
          @r_object.assign_attributes(permitted_params)
          save_resource
        else
          set_notification(false, I18n.t('status.error'), I18n.t('status.not_found', item: default_item_name.titleize))
        end
      end

      def destroy
        @terminal = @r_object = @resource_options[:class].find_by_id(params[:id])
        if @r_object
          if @r_object.can_be_deleted?
            @r_object.destroy
            get_collections
            set_flash_message(I18n.t('success.deleted'), :success)
            set_notification(false, I18n.t('status.success'), I18n.t('success.deleted', item: default_item_name.titleize))
            @destroyed = true
          else
            message = I18n.t('errors.failed_to_delete', item: default_item_name.titleize)
            set_flash_message(message, :failure)
            set_notification(false, I18n.t('status.error'), message)
            @destroyed = false
          end
        else
          set_notification(false, I18n.t('status.error'), I18n.t('status.not_found', item: default_item_name.titleize))
        end

        respond_to do |format|
          format.html {}
          format.js  { 
            js_view_path = @resource_options && @resource_options[:js_view_path] ? "#{@resource_options[:js_view_path]}/destroy" : :destroy 
            render js_view_path
          }
        end

      end

      private

      def get_store
        @store = Store.find_by_id(params[:store_id])
      end

      def get_collections
        @relation = @store.terminals.where("")

        parse_filters
        apply_filters
        
        @terminals = @r_objects = @relation.page(@current_page).per(@per_page)
        
        return true
      end

      def apply_filters
        @relation = @relation.search(@query) if @query
        
        @order_by = "created_at desc" unless @order_by
        @relation = @relation.order(@order_by)
      end

      def configure_filter_settings
        @filter_settings = {
          string_filters: [
            { filter_name: :query }
          ],
          boolean_filters: [],
          reference_filters: [],
          variable_filters: [],
        }
      end

      def configure_filter_ui_settings
        @filter_ui_settings = {}
      end

      def resource_url(obj)
        url_for([:admin, obj.store, obj])
      end

      def resource_controller_configuration
        {
          page_title: "Terminals",
          js_view_path: "/kuppayam/workflows/parrot",
          view_path: "/vyapari/admin/terminals"
        }
      end

      def breadcrumbs_configuration
        {
          heading: "Manage Terminals",
          description: "Listing all Terminals",
          links: [{name: "Home", link: admin_dashboard_path, icon: 'fa-home'}, 
                    {name: "Manage Stores", link: admin_stores_path, icon: 'fa-calendar', active: true}]
        }
      end

      def permitted_params
        params.require(:terminal).permit(:name, :code)
      end

      def set_navs
        set_nav("admin/terminals")
      end

    end
  end
end
