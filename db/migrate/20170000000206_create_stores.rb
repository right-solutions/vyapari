class CreateStores < ActiveRecord::Migration
  def change
    create_table(:stores) do |t|

      t.string :name
      t.string :code, limit: 24
      t.string :store_type, :null => false, :default=>"POS", :limit=>24

      t.string :status, :null => false, :default=>"active", :limit=>16
      
      t.references :region, index: true
      t.references :country, index: true

      t.timestamps
      
    end
    
    add_index :stores, :name
    add_index :stores, :code, :unique => true
  end
end
