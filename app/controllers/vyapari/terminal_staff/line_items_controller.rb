module Vyapari
	module TerminalStaff
	  class LineItemsController < Vyapari::TerminalStaff::ResourceController

      before_action :get_invoice

	  	def create

        ean_sku = permitted_params[:product_id]
        product = Product.where("ean_sku = ?", permitted_params[:product_id]).first

        if product
          @line_item = @invoice.line_items.where("product_id = ?", product.id).first
          unless @line_item
            @line_item = @invoice.line_items.build
            @line_item.product = product
            @line_item.quantity = permitted_params[:quantity] || 1
          end
        else
          @line_item = LineItem.new
          @line_item.quantity = 0
          @line_item.errors.add(:product_id, "Product is not In Stock")
        end

        @line_item.quantity = @line_item.quantity + permitted_params[:quantity].to_f if permitted_params[:quantity]
        @line_item.rate = product.retail_price if product
        begin
          @line_item.rate = permitted_params[:rate].to_f unless permitted_params[:rate]
        rescue
        end

        @r_object = @line_item

        # unless product exists in store
        # @line_item.errors.add(:product_id, "This Product is not In Stock")

        if @line_item.valid?
          @line_item.save
          # recalculate the total amount
          @invoice.save
          set_notification(true, @line_item.product.ean_sku, "Line Item '#{@line_item.product.name}' ADDED")
        else
          error_message = @line_item.try(:product).try(:ean_sku) || I18n.t('status.error')
          set_notification(false, error_message, @line_item.errors.full_messages.join(", "))  
        end

      end

	    private

      def get_invoice
        @invoice = Invoice.find_by_id(params[:invoice_id])
      end

      def permitted_params
        params.require(:line_item).permit(:product_id, :quantity, :rate)
      end

	    def resource_controller_configuration
        {
          collection_name: :line_items,
          item_name: :line_item,
          class: LineItem,
          page_title: "Line Item",
          js_view_path: "/kuppayam/workflows/peacock",
          view_path: "/vyapari/terminal_staff/line_items"
        }
      end

      def breadcrumbs_configuration
	      {
	        heading: "LineItems",
	        description: "Listing the Line Items",
	        links: []
	      }
	    end

	    def set_navs
	      set_nav("terminal_staff/line_items")
	    end

	  end
	end
end

