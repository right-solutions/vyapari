# This migration comes from vyapari (originally 20170000000216)
class CreateStockEntries < ActiveRecord::Migration[5.0]
  def change
    create_table :stock_entries do |t|
      
      t.references :store, index: true
      t.references :product, index: true
      t.references :supplier, index: true
      t.references :stock_bundle, index: true
      t.references :invoice, index: true

      t.decimal :purchased_price, :precision => 16, :scale => 2
      t.decimal :landed_cost, :precision => 16, :scale => 2
      t.decimal :miscellaneous_cost, :precision => 16, :scale => 2
      
      t.decimal :cost_price, :precision => 16, :scale => 2
      t.decimal :discount, :precision => 16, :scale => 2
      t.decimal :wholesale_price, :precision => 16, :scale => 2
      t.decimal :retail_price, :precision => 16, :scale => 2
      
      t.integer :quantity

      # active, damaged, returned, sold, reserved
      t.string :status, :null => false, :default=>"active", :limit=>16
      
      t.timestamps null: false
    end
    
  end
end
