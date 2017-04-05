module Vyapari
  module Admin
    class CountriesController < ResourceController

      private

      def get_collections
        @relation = Country.where("")

        parse_filters
        apply_filters
        
        @countries = @r_objects = @relation.page(@current_page).per(@per_page)

        return true
      end

      def apply_filters
        @relation = @relation.search(@query) if @query
        
        @order_by = "name ASC" unless @order_by
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
          page_title: "Countries",
          current_nav: "admin/countries",
          js_view_path: "/kuppayam/workflows/parrot",
          view_path: "/vyapari/admin/countries"
        }
      end

      def breadcrumbs_configuration
        {
          heading: "Manage Countries",
          description: "Listing all Countries",
          links: [{name: "Home", link: admin_dashboard_path, icon: 'fa-home'}, 
                    {name: "Manage Countries", link: admin_countries_path, icon: 'fa-calendar', active: true}]
        }
      end

      def permitted_params
        params.require(:country).permit(:name, :code)
      end

    end
  end
end
