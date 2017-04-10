# This migration comes from vyapari (originally 20170000000205)
class CreateSuppliers < ActiveRecord::Migration
  def change
    create_table(:suppliers) do |t|

      t.string :name
      t.string :code, limit: 24
      t.text :address
      t.string :city, limit: 56
      t.references :country, index: true

      t.timestamps
      
    end
    
    add_index :suppliers, :name
    add_index :suppliers, :code, :unique => true
  end
end
