module Vyapari
	module TerminalStaff
	  class LineItemsController < Vyapari::TerminalStaff::ResourceController

      before_action :get_invoice

	  	def create

        ean_sku = permitted_params[:product_id].to_s

        product = Product.where("ean_sku = ? ", ean_sku).first

        product_in_stock = false

        # Initialize the line item with quantity 0.0
        @line_item = @invoice.line_items.build(quantity: 0.0)

        # Check if there exists a line item with the invoice.
        @line_item = @invoice.line_items.where("product_id = ?", product.id).first if product
        
        # Initialize the line item again if @line_item is nil
        @line_item = @invoice.line_items.build(product: product, quantity: 0.0) unless @line_item

        # Update the line item quantity and rate
        @line_item.quantity = @line_item.quantity + permitted_params[:quantity].to_f if permitted_params[:quantity]
        @line_item.rate = product.retail_price if product

        # Check if line item is valid
        @line_item.valid?

        # check if product exists in store if product is there
        # add error if out of stock
        # Do this after .valid? method as .valid will clear errors
        product_in_stock = @store.in_stock?(product) if product
        @line_item.errors.add(:product_id, "This Product is Out of Stock") unless product_in_stock

        @r_object = @line_item

        if @line_item.errors.blank?
          
          @line_item.save
          
          # recalculate the gross total amount
          @invoice.reload.save

          set_notification(true, @line_item.product.ean_sku, "Line Item '#{@line_item.product.name}' ADDED")
        else
          if product
            if product_in_stock
              error_message = @line_item.try(:product).try(:ean_sku) || I18n.t('status.error')
              set_notification(false, error_message, @line_item.errors.full_messages.join(", "))  
            else
              error_message = @line_item.try(:product).try(:ean_sku) || I18n.t('status.error')
              set_notification(false, error_message, @line_item.errors[:product_id].first)              
            end
          else
            error_message = @line_item.try(:product).try(:ean_sku) || I18n.t('status.error')
            set_notification(false, error_message, "Product doesn't exist")              
          end
        end

      end

      def destroy
        @line_item = @r_object = @resource_options[:class].find_by_id(params[:id])
        if @r_object
          if @r_object.can_be_deleted?
            @r_object.destroy
            
            # recalculate the gross total amount
            @invoice.reload.save

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

        # respond_to do |format|
        #   format.html {}
        #   format.js  { 
        #     js_view_path = @resource_options && @resource_options[:js_view_path] ? "#{@resource_options[:js_view_path]}/destroy" : :destroy 
        #     render js_view_path
        #   }
        # end

      end

	    private

      def get_invoice
        @invoice = Invoice.find_by_id(params[:invoice_id])
      end

      def permitted_params
        params.require(:line_item).permit(:product_id, :quantity)
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

