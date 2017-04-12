module Vyapari
  module StoreManager
    module Reports
      class InvoicesController < Vyapari::StoreManager::BaseController

        def index
          @relation = Invoice.select("
            invoices.customer_name as customer_name, 
            invoices.customer_address as customer_address, 
            invoices.customer_phone as customer_phone, 
            invoices.customer_email as customer_email, 

            invoices.invoice_number as invoice_number, 
            invoices.invoice_date as invoice_date, 

            invoices.discount as discount, 
            TRUNCATE(invoices.net_total_amount, 2) as net_total_amount, 

            invoices.payment_method as payment_method,
            invoices.credit_card_number as credit_card_number,
            invoices.cheque_number as cheque_number,

            u.name as user_name
            ").
          joins("LEFT JOIN users u ON invoices.user_id = u.id").
          where("invoices.status = 'active'").
          where("invoices.store_id = ?", @store.id)
          
          parse_filters
          apply_filters
          set_columns
          
          @results = @relation.all

          @total = @relation.except(:select).
          select("SUM(invoices.id) as id, 
                  SUM(invoices.net_total_amount) as net_total_amount")

          render_report
        end

        private

        def apply_filters
          @relation = @relation.search(@query) if @query
          
          if @terminal == "null"
            @relation = @relation.where("invoices.terminal_id IS NULL")
          elsif @terminal
            @relation = @relation.where("invoices.terminal_id = ?",@terminal.id)
          end

          if @user == "null"
            @relation = @relation.where("invoices.user_id IS NULL")
          elsif @user
            @relation = @relation.where("invoices.user_id = ?",@user.id)
          end

          if @payment_method == "null"
            @relation = @relation.where("invoices.payment_method IS NULL")
          elsif @payment_method
            @relation = @relation.where("invoices.payment_method = ?",@payment_method)
          end
          
          @relation = @relation.order(@order_by_options[@order_by.to_sym])
        end

        def configure_filter_settings
          
          @order_by_options = {
              invoice_date_desc: "invoices.invoice_date DESC", 
              invoice_date_asc: "invoices.invoice_date ASC", 
              customer_name_desc: "invoices.customer_name DESC",
              customer_name_asc: "invoices.customer_name ASC",
              total_amount_asc: "invoices.net_total_amount DeSC",
              total_amount_asc: "invoices.net_total_amount ASC"
          }
          
          @filter_settings = {
            string_filters: [
              { filter_name: :query },
              { filter_name: :order_by, options: {default: :invoice_date_desc} },
              { filter_name: :payment_method }
            ],

            reference_filters: [
              { filter_name: :user, filter_class: User },
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
              url_method_name: 'store_manager_invoices_report_url',
              filters_to_remove: [:terminal, :store],
              filters_to_add: {},
              show_null_filter_on_top: false
            },
            user: {
              object_filter: true,
              select_label: 'Filter by User',
              current_value: @user,
              values: User.order(:name).all,
              current_filters: @filters,
              url_method_name: 'store_manager_invoices_report_url',
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
              url_method_name: 'store_manager_invoices_report_url',
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
              url_method_name: 'store_manager_invoices_report_url',
              show_all_filter_on_top: true
            },
          }
        end

        def set_columns
          @columns = [
            { column_name: :id, display_name: "Sl.", align: "center", column_type: :integer },
            { column_name: :customer_name, display_name: "Customer Name", align: "center", column_type: :string },
            { column_name: :customer_address, display_name: "Customer Address", align: "center", column_type: :string },
            { column_name: :customer_phone, display_name: "Customer Phone", align: "center", column_type: :string },
            { column_name: :customer_email, display_name: "Customer Email", align: "center", column_type: :string },
            { column_name: :invoice_number, display_name: "Invoice Number", align: "center", column_type: :string },
            { column_name: :invoice_date, display_name: "Invoice Date", align: "center", column_type: :date },
            { column_name: :discount, display_name: "Discount %", align: "center", column_type: :integer },
            { column_name: :net_total_amount, display_name: "Total Amount", align: "right", column_type: :currency },
            { column_name: :payment_method, display_name: "Payment Method", align: "center", column_type: :status },
            { column_name: :credit_card_number, display_name: "Credit Card Number", align: "center", column_type: :string },
            { column_name: :cheque_number, display_name: "Cheque Number", align: "center", column_type: :string },
            { column_name: :user_name, display_name: "User", align: "center", column_type: :string }
          ]

          if params[:cols]
            @selected_columns = params[:cols].map{|x| x.to_sym}
          else
            @selected_columns = [:id, :invoice_number, :invoice_date, :net_total_amount]
          end
        end

        def breadcrumbs_configuration
          {
            heading: "Invoices Report",
            description: "Invoices Report",
            links: [{name: "Change Store", link: user_dashboard_path, icon: 'fa-desktop'}, 
                      {name: @store.name, link: store_manager_dashboard_path(@store), icon: 'fa-dashboard'}, 
                      {name: "Invoices Reports", link: nil, icon: 'fa-list', active: true}]
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
                      :disposition => "attachment; filename=invoice-report.csv", 
                      :filename => "invoice-report.csv"
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
