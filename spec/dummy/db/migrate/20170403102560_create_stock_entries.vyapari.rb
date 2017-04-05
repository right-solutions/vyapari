# This migration comes from vyapari (originally 20170000000216)
class CreateStockEntries < ActiveRecord::Migration[5.0]
  def change
    create_table :stock_entries do |t|
      
      t.references :store
      t.references :product
      t.references :supplier
      t.references :stock_bundle
      t.references :invoice
      
      t.integer :quantity

      # active, damaged, returned, sold, reserved
      t.string :status, :null => false, :default=>"active", :limit=>16
      
      t.timestamps null: false
    end
    
  end
end
