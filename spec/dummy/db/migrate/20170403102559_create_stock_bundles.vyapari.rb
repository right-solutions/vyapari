# This migration comes from vyapari (originally 20170000000215)
class CreateStockBundles < ActiveRecord::Migration
  def change
    create_table(:stock_bundles) do |t|
      t.datetime   :uploaded_date
      t.references :store, index: true
      t.references :supplier, index: true
      t.references :uploader, references: :users
      t.string     :name
      t.string     :file
      t.string     :error_summary
      t.string     :error_details
      t.string     :error_file
      t.string     :status, :null => false, :default=>"pending", :limit=>16
      t.timestamps
    end
  end
end