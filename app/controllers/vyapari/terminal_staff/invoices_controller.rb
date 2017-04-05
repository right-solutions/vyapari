module Vyapari
	module TerminalStaff
	  class InvoicesController < Vyapari::TerminalStaff::ResourceController

	  	def new
        @invoice = @r_object = Invoice.new
        @invoice.terminal = @terminal
        @invoice.store = @store
        @invoice.user = @current_user
        @invoice.status = Invoice::DRAFT
        @invoice.generate_temporary_invoice_number
        @invoice.invoice_date = Time.now
        @invoice.save
        render_show
      end

      def edit
        @invoice = @r_object = Invoice.find_by_id(params[:id])
        render_show
      end

      def update

        @invoice = @r_object = Invoice.find_by_id(params[:id])
        @invoice.invoice_date = Time.now
        @invoice.assign_attributes(permitted_params)

        if @invoice.valid?
          @invoice.save
          @invoice.generate_real_invoice_number!
          @invoice.activate!
          set_notification(true, @invoice.invoice_number, "Invoice '#{@invoice.invoice_number}' SAVED")
        else
          error_message = @invoice.invoice_number || I18n.t('status.error')
          set_notification(false, error_message, @invoice.errors.full_messages.join(", "))  
        end
        render_show
      end

	    private

      def permitted_params
        params.require(:invoice).permit(:discount, :adjustment, :money_taken, :notes, :payment_method)
      end

	    def resource_controller_configuration
        {
          collection_name: :invoices,
          item_name: :invoice,
          class: Invoice,
          page_title: "#{@terminal.name} - Invoices",
          js_view_path: "/kuppayam/workflows/peacock",
          view_path: "/vyapari/terminal_staff/invoices"
        }
      end

      def breadcrumbs_configuration
	      {
	        heading: "Invoices - #{@terminal.name}",
	        description: "Listing the invoices - #{@terminal.name}",
	        links: [
            {name: "Home", link: store_manager_stores_path, icon: 'fa-building-o'},
            {name: @store.name, link: store_manager_dashboard_path(@store), icon: 'fa-dashboard'},
            {name: "Stock Entries", link: nil, icon: 'fa-truck', active: true},
            {name: @terminal.name, link: terminal_staff_dashboard_path(@terminal), icon: 'fa-desktop'},
            {name: "Invoices", link: nil, icon: 'fa-file', active: true}
          ]
	      }
	    end

      def get_collections
        @relation = @terminal.invoices.where("")

        parse_filters
        apply_filters
        
        @invoices = @r_objects = @relation.page(@current_page).per(@per_page)
        
        return true
      end

      def apply_filters
        @relation = @relation.search(@query) if @query
        
        # if @terminal == "null"
        #   @relation = @relation.where("invoices.terminal_id IS NULL")
        # elsif @terminal
        #   @relation = @relation.where("invoices.terminal_id = ?", @terminal.id)
        # end

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
            { filter_name: :terminal, filter_class: Terminal },
          ],
          variable_filters: [],
        }
      end

      def configure_filter_ui_settings
        @filter_ui_settings = {}
      end

      def resource_url(obj)
        url_for([:terminal_staff, @terminal, obj])
      end

	    def set_navs
        set_nav("terminal_staff/invoices")
	    end

	  end
	end
end
