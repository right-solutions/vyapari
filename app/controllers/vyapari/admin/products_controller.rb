module Vyapari
  module Admin
    class ProductsController < ResourceController

      def mark_as_featured
        @product = @r_object = Product.find(params[:id])
        @product.update_attribute(:featured, true) if @product.published?
        render_row
      end

      def remove_from_featured
        @product = @r_object = Product.find(params[:id])
        @product.update_attribute(:featured, false) if @product.featured?
        render_row
      end

      private

      def get_collections
        @relation = Product.where("")

        parse_filters
        apply_filters
        
        @products = @r_objects = @relation.page(@current_page).per(@per_page)

        return true
      end

      def apply_filters
        @relation = @relation.search(@query) if @query
        
        @order_by = "priority DESC, name ASC" unless @order_by
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
          page_title: "Products",
          js_view_path: "/kuppayam/workflows/parrot",
          view_path: "/vyapari/admin/products"
        }
      end

      def breadcrumbs_configuration
        {
          heading: "Manage Products",
          description: "Listing all Products",
          links: [{name: "Home", link: admin_dashboard_path, icon: 'fa-home'}, 
                    {name: "Manage Products", link: admin_products_path, icon: 'fa-calendar', active: true}]
        }
      end

      def permitted_params
        params.require(:product).permit(:name, :one_liner, :ean_sku, :reference_number, :brand_id, :category_id, :status, :featured)
      end

      def set_navs
        set_nav("admin/products")
      end

    end
  end
end
