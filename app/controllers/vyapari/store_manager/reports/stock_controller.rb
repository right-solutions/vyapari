module Vyapari
  module StoreManager
    module Reports
      class StockController < Vyapari::StoreManager::BaseController


        # select MAX(p.id) as id, MAX(p.name) as name, 
        # MAX(p.ean_sku) as ean_sku, 
        # MAX(p.purchased_price) as purchased_price, 
        # MAX(p.landed_price) as landed_price, 
        # MAX(p.selling_price) as selling_price, 
        # MAX(p.retail_price) as retail_price, 
        # SUM(se.quantity) as se_quantity, 
        # MAX(se.status) as se_status 
        # from products p left join stock_entries se 
        # on se.product_id = p.id group by p.id;
        def index
          @relation = Product.select("MAX(products.id) as id, 
            MAX(products.name) as name, 
            MAX(products.ean_sku) as ean_sku, 
            MAX(products.purchased_price) as purchased_price, 
            MAX(products.landed_price) as landed_price, 
            MAX(products.selling_price) as selling_price, 
            MAX(products.retail_price) as retail_price, 
            MAX(se.status) as se_status, 
            SUM(se.quantity) as se_quantity").
          joins("LEFT JOIN stock_entries se ON se.product_id = products.id")
          
          parse_filters
          apply_filters

          @results = @relation.group("products.id")
          @total = @relation.except(:select).
          select("SUM(products.id) as id, 
                  SUM(products.purchased_price) as purchased_price, 
                  SUM(products.landed_price) as landed_price, 
                  SUM(products.selling_price) as selling_price, 
                  SUM(products.retail_price) as retail_price")

          render_report
        end
        
        private

        def apply_filters
          @relation = @relation.search(@query) if @query
          # @relation = @relation.where("se.se_status = ?", @status) if @status
          
          @order_by = "products.name ASC, products.ean_sku ASC" unless @order_by
          @relation = @relation.order(@order_by)
        end

        def configure_filter_settings
          @filter_settings = {
            string_filters: [
              { filter_name: :query },
              { filter_name: :status, options: {default: :pending} }
            ],

            reference_filters: [
              { filter_name: :brand, filter_class: Brand },
              { filter_name: :category, filter_class: Category },
            ],

            variable_filters: [
              { variable_name: :store, filter_name: :store },
              { variable_name: :terminal, filter_name: :terminal },
            ]
          }
        end

        def configure_filter_ui_settings
          @filter_ui_settings = {}
        end

        def filter_config_ui
          return @filter_config_ui if @filter_config_ui
          @filter_config_ui = {
            brand: {
              object_filter: true,
              display_name: 'Select Brand',
              current_value: @brand,
              values: Brand.order(:name).all,
              current_filters: @filters,
              url_method_name: 'root_url',
              filters_to_remove: [:terminal, :store],
              filters_to_add: {},
              show_null_filter_on_top: true
            },
            category: {
              object_filter: true,
              display_name: 'Select Brand Category',
              current_value: @category,
              values: Category.order(:name).all,
              current_filters: @filters,
              url_method_name: 'root_url',
              filters_to_remove: [:terminal, :store],
              filters_to_add: {},
              show_null_filter_on_top: true
            }
          }
        end

        def breadcrumbs_configuration
          {
            heading: "Stock Report",
            description: "In Stock Report",
            links: [{name: "Home", link: user_dashboard_path, icon: 'fa-dashboard'}, 
                      {name: "Reports", link: user_dashboard_path, icon: 'fa-calendar', active: true}]
          }
        end

      	def set_navs
          set_nav("store_manager/reports")
        end

        def render_report
         respond_to do |format|
          format.html {}
          format.csv { send_data generate_csv(@results), filename: "#{params[:action]}_#{Date.today}.csv" }
          format.pdf do
            render :pdf => "#{@heading} (As on #{Date.today})"
                   #:disposition => 'attachment'
                   #:show_as_html => true
          end
        end
      end

      end
    end
  end
end
