module Vyapari
  module Admin
    class CategoriesController < ResourceController

      def make_parent
        @category = @r_object = Category.find(params[:id])
        if @category
          @category.parent = nil
          if @category.valid?
            @category.save
            set_notification(true, I18n.t('status.success'), I18n.t('state.changed', item: default_item_name.titleize, new_state: "made as parent"))
          else
            set_notification(false, I18n.t('status.error'), I18n.translate("error"), @category.errors.full_messages.join("<br>"))
          end
        else
          set_notification(false, I18n.t('status.not_found'), I18n.t('status.not_found', item: default_item_name.titleize))
        end
        render_row
      end

      def mark_as_featured
        @category = @r_object = Category.find(params[:id])
        if @category
          @category.featured = true
          if @category.valid?
            @category.save
            set_notification(true, I18n.t('status.success'), I18n.t('state.changed', item: default_item_name.titleize, new_state: "featured"))
          else
            set_notification(false, I18n.t('status.error'), I18n.translate("error"), @category.errors.full_messages.join("<br>"))
          end
        else
          set_notification(false, I18n.t('status.not_found'), I18n.t('status.not_found', item: default_item_name.titleize))
        end
        render_row
      end

      def remove_from_featured
        @category = @r_object = Brand.find(params[:id])
        if @category
          @category.featured = false
          if @category.valid?
            @category.save
            set_notification(true, I18n.t('status.success'), I18n.t('state.changed', item: default_item_name.titleize, new_state: "featured"))
          else
            set_notification(false, I18n.t('status.error'), I18n.translate("error"), @category.errors.full_messages.join("<br>"))
          end
        else
          set_notification(false, I18n.t('status.not_found'), I18n.t('status.not_found', item: default_item_name.titleize))
        end
        render_row
      end

      private

      def get_collections
        @relation = Category.includes(:parent).where("")

        parse_filters
        apply_filters
        
        @categories = @r_objects = @relation.page(@current_page).per(@per_page)

        return true
      end

      def apply_filters
        @relation = @relation.search(@query) if @query
        
        @order_by = "parent_id ASC, priority DESC, name ASC" unless @order_by
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
          page_title: "Categories",
          js_view_path: "/kuppayam/workflows/parrot",
          view_path: "/vyapari/admin/categories"
        }
      end

      def breadcrumbs_configuration
        {
          heading: "Manage Categories",
          description: "Listing all Categories",
          links: [{name: "Home", link: admin_dashboard_path, icon: 'fa-home'}, 
                    {name: "Manage Categories", link: admin_categories_path, icon: 'fa-calendar', active: true}]
        }
      end

      def permitted_params
        params.require(:category).permit(:name, :one_liner, :parent_id, :status, :featured)
      end

      def set_navs
        set_nav("admin/categories")
      end

    end
  end
end
