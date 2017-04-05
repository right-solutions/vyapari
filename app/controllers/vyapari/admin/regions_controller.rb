module Vyapari
  module Admin
    class RegionsController < ResourceController

      private

      def get_collections
        @relation = Region.where("")

        parse_filters
        apply_filters
        
        @regions = @r_objects = @relation.page(@current_page).per(@per_page)

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
          page_title: "Regions",
          js_view_path: "/kuppayam/workflows/parrot",
          view_path: "/vyapari/admin/regions"
        }
      end

      def breadcrumbs_configuration
        {
          heading: "Manage Regions",
          description: "Listing all Regions",
          links: [{name: "Home", link: admin_dashboard_path, icon: 'fa-home'}, 
                    {name: "Manage Regions", link: admin_regions_path, icon: 'fa-calendar', active: true}]
        }
      end

      def permitted_params
        params.require(:region).permit(:name, :code, :country_id)
      end

      def set_navs
        set_nav("admin/regions")
      end

    end
  end
end
