module Vyapari
  module StoreManager
    class StockBundlesController < ResourceController

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
        @stock_bundle = @r_object = @resource_options[:class].find_by_id(params[:id])
        set_notification(false, I18n.t('status.error'), I18n.t('status.not_found', item: default_item_name.titleize)) unless @r_object
        render_accordingly
      end

      def download_original_file
        @stock_bundle = @r_object = @resource_options[:class].find_by_id(params[:id])
        send_file @stock_bundle.file.file.path
      end

      def download_error_file
        @stock_bundle = @r_object = @resource_options[:class].find_by_id(params[:id])
        send_file @stock_bundle.error_file.file.path
      end

      def new
        @stock_bundle = @r_object = @resource_options[:class].new(store: @store)
        render_accordingly
      end

      def edit
        @stock_bundle = @r_object = @resource_options[:class].find_by_id(params[:id])
        set_notification(false, I18n.t('status.error'), I18n.t('status.not_found', item: default_item_name.titleize)) unless @r_object
        render_accordingly
      end

      def create
        @stock_bundle = @r_object = @resource_options[:class].new(store: @store)
        @stock_bundle.assign_attributes(permitted_params)
        @stock_bundle.store = @store
        @stock_bundle.status = :pending
        
        @stock_bundle.uploader = @current_user
        @stock_bundle.uploaded_date = Time.now

        if @stock_bundle.valid?
          @stock_bundle.save!
          if @stock_bundle.parse_stocks
            @stock_bundle.approve!
            set_flash_message("#{I18n.t('status.success')} - #{I18n.t('state.changed', item: default_item_name.titleize, new_state: "uploaded")}", :success)
            set_notification(true, I18n.t('status.success'), I18n.t('state.changed', item: default_item_name.titleize, new_state: "uploaded"))
          else
            message = "Stock Bundle #{@stock_bundle.display_name} has been uploaded successfully. However, some of the jobs had some data issues. You need to approve this job bundle manually."
            set_flash_message(message, :warning)
            set_notification(false, I18n.t('status.error'), message)
          end
        else
          message = "Error! Stock Bundle #{@stock_bundle.display_name} was not uploaded. #{@stock_bundle.errors.full_messages.to_sentence}"
          puts "Error! #{message}".red
          set_flash_message(message = message, :danger)
          set_notification(false, I18n.t('status.error'), message)
        end

        render layout: "kuppayam/document_upload"

      end

      def update
        @stock_bundle = @r_object = @resource_options[:class].find_by_id(params[:id])
        @stock_bundle.assign_attributes(permitted_params)
        @stock_bundle.store = @store
        @stock_bundle.status = :pending
        
        @stock_bundle.uploader = @current_user
        @stock_bundle.uploaded_date = Time.now

        if @stock_bundle.valid?
          @stock_bundle.save!
          if @stock_bundle.parse_stocks
            @stock_bundle.approve!
            set_flash_message("#{I18n.t('status.success')} - #{I18n.t('state.changed', item: default_item_name.titleize, new_state: "uploaded")}", :success)
            set_notification(true, I18n.t('status.success'), I18n.t('state.changed', item: default_item_name.titleize, new_state: "uploaded"))
          else
            message = "Stock Bundle #{@stock_bundle.display_name} has been uploaded successfully. However, some of the jobs had some data issues. You need to approve this job bundle manually."
            set_flash_message(message, :warning)
            set_notification(false, I18n.t('status.error'), message)
          end
        else
          message = "Error! Stock Bundle #{@stock_bundle.display_name} was not uploaded. #{@stock_bundle.errors.full_messages.to_sentence}"
          puts "Error! #{message}".red
          set_flash_message(message = message, :danger)
          set_notification(false, I18n.t('status.error'), message)
        end

        render layout: "kuppayam/document_upload"

      end

      def destroy
        @stock_bundle = @r_object = @resource_options[:class].find_by_id(params[:id])
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
        @relation = @store.stock_bundles.includes(:store, :supplier, :uploader).where("")

        parse_filters
        apply_filters
        
        @stock_bundles = @r_objects = @relation.page(@current_page).per(@per_page)
        
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
          collection_name: :stock_bundles,
          item_name: :stock_bundle,
          class: StockBundle,
          page_title: "#{@store.name} - Stock Bundle",
          js_view_path: "/kuppayam/workflows/peacock",
          view_path: "/vyapari/store_manager/stock_bundles"
        }
      end

      def breadcrumbs_configuration
        {
          heading: "#{@store.name} - Stock Bundle",
          description: "Listing all the stock at #{@store.name}",
          links: [
            {name: "Home", link: user_dashboard_path, icon: 'fa-dashboard'},
            {name: @store.name, link: store_manager_dashboard_path(@store), icon: 'fa-dashboard'},
            {name: "Stock Bundle", link: nil, icon: 'fa-truck', active: true}
          ]
        }
      end

      def permitted_params
        params.require(:stock_bundle).permit(:name, :supplier_id, :file)
      end

      def set_navs
        set_nav("store_manager/stocks")
      end

    end
  end
end
