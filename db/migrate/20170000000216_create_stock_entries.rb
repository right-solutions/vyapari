class CreateStockEntries < ActiveRecord::Migration[5.0]
  def change
    create_table :stock_entries do |t|
      
      t.references :store, index: true
      t.references :product, index: true
      t.references :supplier, index: true
      t.references :stock_bundle, index: true
      t.references :invoice, index: true
      
      t.integer :quantity

      # active, damaged, returned, sold, reserved
      t.string :status, :null => false, :default=>"active", :limit=>16
      
      t.timestamps null: false
    end
    
  end
end
