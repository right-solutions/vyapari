module Vyapari
  module Admin
    class ExchangeRatesController < ResourceController

      private

      def get_collections
        @relation = ExchangeRate.where("")

        parse_filters
        apply_filters
        
        @exchange_rates = @r_objects = @relation.page(@current_page).per(@per_page)

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
          page_title: "Manage Countries",
          collection_name: :exchange_rates,
          item_name: :exchange_rate,
          class: ExchangeRate,
          js_view_path: "/kuppayam/workflows/parrot",
          view_path: "/vyapari/admin/exchange_rates"
        }
      end

      def breadcrumbs_configuration
        {
          heading: "Manage Exchange Rates",
          description: "Listing all Exchange Rates",
          links: [{name: "Home", link: admin_dashboard_path, icon: 'fa-home'}, 
                    {name: "Manage Exchange Rates", link: admin_exchange_rates_path, icon: 'fa-calendar', active: true}]
        }
      end

      def permitted_params
        params.require(:exchange_rate).permit(:currency_name, :value, :effective_date, :country_id)
      end

      def set_navs
        set_nav("admin/exchange_rates")
      end

    end
  end
end
