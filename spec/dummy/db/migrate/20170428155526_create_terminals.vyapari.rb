# This migration comes from vyapari (originally 20170000000207)
class CreateTerminals < ActiveRecord::Migration[5.0]
  def change
    create_table :terminals do |t|
      
      t.string :name
      t.string :code, limit: 24

      t.string :status, :null => false, :default=>"active", :limit=>16

      t.references :store, index: true
      
      t.timestamps null: false
    end

    add_index :terminals, :name
    add_index :terminals, :code, :unique => true
  end
end
