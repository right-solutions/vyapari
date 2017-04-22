require 'csv'

module Vyapari
  module StoreManager
    module Reports
      class SalesController < Vyapari::StoreManager::BaseController


        def index
          @relation = StockEntry.select("p.name as product_name, 
            p.ean_sku as ean_sku, 
            stock_entries.purchased_price as purchased_price, 
            stock_entries.landed_cost as landed_cost,
            stock_entries.miscellaneous_cost as miscellaneous_cost,
            stock_entries.discount as discount,
            stock_entries.cost_price as cost_price, 
            stock_entries.wholesale_price as wholesale_price, 
            stock_entries.retail_price as retail_price, 
            ((stock_entries.retail_price - stock_entries.cost_price) * stock_entries.quantity) as profit, 
            stock_entries.quantity as quantity, 
            u.name as user_name, 
            i.invoice_number as invoice_number, 
            i.invoice_date as invoice_date, 
            i.payment_method as payment_method").
          joins("LEFT JOIN products p ON stock_entries.product_id = p.id").
          joins("LEFT JOIN invoices i ON stock_entries.invoice_id = i.id").
          joins("LEFT JOIN users u ON i.user_id = u.id").
          where("stock_entries.status = 'sold'").
          where("stock_entries.store_id = ?", @store.id)
          
          parse_filters
          apply_filters
          set_columns

          #.page(@current_page).per(@per_page)
          @results = @relation.all

          @total = @relation.except(:select).
          select("SUM(stock_entries.id) as id, 
                  SUM(stock_entries.quantity) as quantity,
                  SUM(stock_entries.purchased_price) as purchased_price,
                  SUM(stock_entries.landed_cost) as landed_cost,
                  SUM(stock_entries.miscellaneous_cost) as miscellaneous_cost,
                  SUM(stock_entries.discount) as discount,
                  SUM(stock_entries.cost_price) as cost_price,
                  SUM(stock_entries.wholesale_price) as wholesale_price,
                  SUM(stock_entries.retail_price) as retail_price,
                  SUM((stock_entries.retail_price - stock_entries.cost_price) * stock_entries.quantity) as profit")

          render_report
        end

        private

        def apply_filters
          @relation = @relation.search(@query) if @query
          # @relation = @relation.where("se.se_status = ?", @status) if @status

          if @terminal == "null"
            @relation = @relation.where("i.terminal_id IS NULL")
          elsif @terminal
            @relation = @relation.where("i.terminal_id = ?",@terminal.id)
          end

          if @brand == "null"
            @relation = @relation.where("p.brand_id IS NULL")
          elsif @brand
            @relation = @relation.where("p.brand_id = ?",@brand.id)
          end

          if @category == "null"
            @relation = @relation.where("p.category_id IS NULL")
          elsif @category
            @relation = @relation.where("p.category_id = ?",@category.id)
          end

          if @payment_method == "null"
            @relation = @relation.where("i.payment_method IS NULL")
          elsif @payment_method
            @relation = @relation.where("i.payment_method = ?",@payment_method)
          end
          
          @relation = @relation.order(@order_by_options[@order_by.to_sym])
        end

        def set_columns
          @columns = [
            { column_name: :id, display_name: "Sl.", align: "center", column_type: :integer },
            { column_name: :product_name, display_name: "Product Name", align: "left", column_type: :string },
            { column_name: :ean_sku, display_name: "EAN/SKU", align: "left", column_type: :string },
            { column_name: :quantity, display_name: "Quantity", align: "center", column_type: :integer },
            { column_name: :invoice_number, display_name: "Invoice Number", align: "center", column_type: :string },
            { column_name: :invoice_date, display_name: "Invoice Date", align: "center", column_type: :date },
            { column_name: :payment_method, display_name: "Payment Method", align: "center", column_type: :status },
            { column_name: :purchased_price, display_name: "Purchased Price", align: "right", column_type: :currency },
            { column_name: :landed_cost, display_name: "Landed Cost", align: "right", column_type: :currency },
            { column_name: :miscellaneous_cost, display_name: "Miscellaneous Price", align: "right", column_type: :currency },
            { column_name: :discount, display_name: "Discount", align: "right", column_type: :currency },
            { column_name: :cost_price, display_name: "Cost Price", align: "right", column_type: :currency },
            { column_name: :wholesale_price, display_name: "Wholesale Price", align: "right", column_type: :currency },
            { column_name: :retail_price, display_name: "Retail Price", align: "right", column_type: :currency },
            { column_name: :profit, display_name: "Profit", align: "right", column_type: :currency },
            { column_name: :user_name, display_name: "User", align: "center", column_type: :string }
          ]

          if params[:cols]
            @selected_columns = params[:cols].map{|x| x.to_sym}
          else
            @selected_columns = [:id, :product_name, :ean_sku, :quantity, :invoice_number, :cost_price, :retail_price, :profit]
          end
        end

        def configure_filter_settings
          
          @order_by_options = {
              invoice_date_desc: "i.invoice_date DESC", 
              invoice_date_asc: "i.invoice_date ASC", 
              quantity_desc: "stock_entries.quantity DESC",
              quantity_asc: "stock_entries.quantity ASC",
              product_name_asc: "p.name ASC, p.ean_sku ASC",
              product_name_desc: "p.name DESC, p.ean_sku DESc"}
          
          @filter_settings = {
            string_filters: [
              { filter_name: :query },
              { filter_name: :order_by, options: {default: :invoice_date_desc} },
              { filter_name: :payment_method }
            ],

            reference_filters: [
              { filter_name: :brand, filter_class: Brand },
              { filter_name: :category, filter_class: Category },
              { filter_name: :terminal, filter_class: Terminal },
            ],

            variable_filters: [
              { variable_name: :store, filter_name: :store }
            ]
          }
        end

        def configure_filter_ui_settings
          @filter_ui_settings = {
            terminal: {
              object_filter: true,
              select_label: 'Filter by Terminal',
              current_value: @terminal,
              values: @store.terminals.order(:name).all,
              current_filters: @filters,
              url_method_name: 'store_manager_sales_report_url',
              filters_to_remove: [:terminal, :store],
              filters_to_add: {},
              show_null_filter_on_top: false
            },
            brand: {
              object_filter: true,
              select_label: 'Filter by Brand',
              current_value: @brand,
              values: Brand.order(:name).all,
              current_filters: @filters,
              url_method_name: 'store_manager_sales_report_url',
              filters_to_remove: [:terminal, :store],
              filters_to_add: {},
              show_null_filter_on_top: true
            },
            category: {
              object_filter: true,
              select_label: 'Filter by Category',
              current_value: @category,
              values: Category.order(:name).all,
              current_filters: @filters,
              url_method_name: 'store_manager_sales_report_url',
              filters_to_remove: [:terminal, :store],
              filters_to_add: {},
              show_null_filter_on_top: true
            },
            payment_method: {
              object_filter: false,
              select_label: "Filter by Payment Method",
              display_hash: Invoice::PAYMENT_METHOD_REVERSE,
              current_value: @payment_method,
              values: Invoice::PAYMENT_METHOD,
              current_filters: @filters,
              filters_to_remove: [],
              filters_to_add: {},
              url_method_name: 'store_manager_sales_report_url',
              show_all_filter_on_top: true
            },
            order_by: {
              object_filter: false,
              select_label: "Order by",
              display_hash: Hash[@order_by_options.keys.map {|i| [i, i.to_s.titleize]}],
              current_value: @order_by,
              values: Hash[@order_by_options.keys.map {|i| [i.to_s.titleize, i]}],
              current_filters: @filters,
              filters_to_remove: [],
              filters_to_add: {},
              url_method_name: 'store_manager_sales_report_url',
              show_all_filter_on_top: true
            },
          }
        end

        def breadcrumbs_configuration
          {
            heading: "Sales Report",
            description: "Sales Report",
            links: [{name: "Change Store", link: user_dashboard_path, icon: 'fa-desktop'}, 
                      {name: @store.name, link: store_manager_dashboard_path(@store), icon: 'fa-dashboard'}, 
                      {name: "Sales Reports", link: nil, icon: 'fa-list', active: true}]
          }
        end

      	def set_navs
          set_nav("store_manager/reports")
        end

        def render_report
          respond_to do |format|
            format.html {}
            format.csv do 
              send_data generate_csv(@results), 
                      :type => 'text/csv; charset=utf-8; header=present', 
                      :disposition => "attachment; filename=sales-report.csv", 
                      :filename => "sales-report.csv"
            end
            format.pdf do
              render :pdf => "#{@heading} (As on #{Date.today})"
                   #:disposition => 'attachment'
                   #:show_as_html => true
            end
          end
        end

        def generate_csv(results)
          
          CSV.generate(headers: true) do |csv|
            # Adding the headings
            csv << @columns.select{|col_item| @selected_columns.include?(col_item[:column_name])}.collect{|x| x[:display_name]}

            # Adding the results
            @results.each_with_index do |result, i|
              
              # Remove Id as we get it with i in each_with_index
              cols_without_id = @columns.reject{|col_item| col_item[:column_name] == :id}
              
              # Select columns which are selected by the user / default
              selected_cols = cols_without_id.select{|col_item| @selected_columns.include?(col_item[:column_name]) }
              
              # Initialize result row with just serial number
              result_data = [i+1]

              # Iterate selected columns and populate the result data
              selected_cols.each do |col_item|

                case col_item[:column_type]
                when :string, :integer
                  result_data << result.send(col_item[:column_name])
                when :status
                  result_data << result.send(col_item[:column_name]).titleize
                when :currency
                  result_data << sprintf("%.2f", result.send(col_item[:column_name]))
                when :date
                  result_data << result.send(col_item[:column_name]).strftime("%d-%m-%Y")
                else
                  result_data << result.send(col_item[:column_name])
                end

              end

              # Append to CSV
              csv << result_data
            end
          end

        end

      end
    end
  end
end
