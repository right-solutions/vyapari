# This migration comes from vyapari (originally 20140402113215)
class CreateRegions < ActiveRecord::Migration
  def change
    create_table(:regions) do |t|

      t.string :name, limit: 128
      t.string :code, limit: 16
      
      t.references :country, index: true

      t.timestamps
    end
    
    add_index :regions, :name
    add_index :regions, :code, :unique => true
  end
end
