module Vyapari
  module Admin
    class StoresController < ResourceController

      private

      def get_collections
        @relation = Store.where("")

        parse_filters
        apply_filters
        
        @stores = @r_objects = @relation.page(@current_page).per(@per_page)
        
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

      def resource_controller_configuration
        {
          page_title: "Stores",
          js_view_path: "/kuppayam/workflows/peacock",
          view_path: "/vyapari/admin/stores"
        }
      end

      def breadcrumbs_configuration
        {
          heading: "Manage Stores",
          description: "Listing all Stores",
          links: [{name: "Home", link: admin_dashboard_path, icon: 'fa-home'}, 
                    {name: "Manage Stores", link: admin_stores_path, icon: 'fa-calendar', active: true}]
        }
      end

      def permitted_params
        params.require(:store).permit(:name, :code, :store_type, :region_id, :country_id)
      end

      def set_navs
        set_nav("admin/stores")
      end

    end
  end
end
