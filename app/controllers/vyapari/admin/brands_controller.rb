module Vyapari
  module Admin
    class BrandsController < ResourceController

      def mark_as_featured
        @brand = @r_object = Brand.find(params[:id])
        if @brand
          @brand.featured = true
          if @brand.valid?
            @brand.save
            set_notification(true, I18n.t('status.success'), I18n.t('state.changed', item: default_item_name.titleize, new_state: "featured"))
          else
            set_notification(false, I18n.t('status.error'), I18n.translate("error"), @brand.errors.full_messages.join("<br>"))
          end
        else
          set_notification(false, I18n.t('status.not_found'), I18n.t('status.not_found', item: default_item_name.titleize))
        end
        render_row
      end

      def remove_from_featured
        @brand = @r_object = Brand.find(params[:id])
        if @brand
          @brand.featured = false
          if @brand.valid?
            @brand.save
            set_notification(true, I18n.t('status.success'), I18n.t('state.changed', item: default_item_name.titleize, new_state: "featured"))
          else
            set_notification(false, I18n.t('status.error'), I18n.translate("error"), @brand.errors.full_messages.join("<br>"))
          end
        else
          set_notification(false, I18n.t('status.not_found'), I18n.t('status.not_found', item: default_item_name.titleize))
        end
        render_row
      end

      private

      def get_collections
        @relation = Brand.where("")

        parse_filters
        apply_filters
        
        @brands = @r_objects = @relation.page(@current_page).per(@per_page)

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
          page_title: "Brands",
          js_view_path: "/kuppayam/workflows/parrot",
          view_path: "/vyapari/admin/brands"
        }
      end

      def breadcrumbs_configuration
        {
          heading: "Manage Brands",
          description: "Listing all Brands",
          links: [{name: "Home", link: admin_dashboard_path, icon: 'fa-home'}, 
                    {name: "Manage Brands", link: admin_brands_path, icon: 'fa-calendar', active: true}]
        }
      end

      def permitted_params
        params.require(:brand).permit(:name, :featured, :status)
      end

      def set_navs
        set_nav("admin/brands")
      end

    end
  end
end
