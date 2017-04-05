module Vyapari
  module StoreManager
    class StockEntriesController < ResourceController

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
        @stock_entry = @r_object = @resource_options[:class].find_by_id(params[:id])
        set_notification(false, I18n.t('status.error'), I18n.t('status.not_found', item: default_item_name.titleize)) unless @r_object
        render_accordingly
      end

      def new
        @stock_entry = @r_object = @resource_options[:class].new(store: @store)
        render_accordingly
      end

      def edit
        @stock_entry = @r_object = @resource_options[:class].find_by_id(params[:id])
        set_notification(false, I18n.t('status.error'), I18n.t('status.not_found', item: default_item_name.titleize)) unless @r_object
        render_accordingly
      end

      def create
        @stock_entry = @r_object = @resource_options[:class].new(store: @store)
        @r_object.assign_attributes(permitted_params)
        @r_object.store = @store
        save_resource
      end

      def update
        @stock_entry = @r_object = @resource_options[:class].find_by_id(params[:id])
        if @r_object
          @r_object.assign_attributes(permitted_params)
          @r_object.store = @store
          save_resource
        else
          set_notification(false, I18n.t('status.error'), I18n.t('status.not_found', item: default_item_name.titleize))
        end
      end

      def destroy
        @stock_entry = @r_object = @resource_options[:class].find_by_id(params[:id])
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

      def get_collections
        @relation = @store.stock_entries.where("")

        parse_filters
        apply_filters
        
        @stock_entries = @r_objects = @relation.page(@current_page).per(@per_page)
        
        return true
      end

      def apply_filters

        @relation = @relation.search(@query) if !@query.blank?
        
        if @stock_bundle == "null"
          @relation = @relation.where("stock_entries.stock_bundle_id IS NULL")
        elsif @stock_bundle
          @relation = @relation.where("stock_entries.stock_bundle_id = ?", @stock_bundle.id)
        end

        @order_by = "created_at desc" unless @order_by
        @relation = @relation.order(@order_by)
      end

      def configure_filter_settings
        @filter_settings = {
          string_filters: [
            { filter_name: :query }
          ],
          boolean_filters: [],
          reference_filters: [
            { filter_name: :stock_bundle, filter_class: StockBundle },
          ],
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
          collection_name: :stock_entries,
          item_name: :stock_entry,
          class: StockEntry,
          page_title: "#{@store.name} - Stock Entries",
          js_view_path: "/kuppayam/workflows/parrot",
          view_path: "/vyapari/store_manager/stock_entries"
        }
      end

      def breadcrumbs_configuration
        {
          heading: "#{@store.name} - Stock Entries",
          description: "Listing all the stock at #{@store.name}",
          links: [
            {name: "Home", link: store_manager_stores_path, icon: 'fa-building-o'},
            {name: @store.name, link: store_manager_dashboard_path(@store), icon: 'fa-dashboard'},
            {name: "Stock Entries", link: nil, icon: 'fa-truck', active: true}
          ]
        }
      end

      def permitted_params
        params.require(:stock_entry).permit(:product_id, :quantity, :status)
      end

      def set_navs
        set_nav("store_manager/stocks")
      end

    end
  end
end
