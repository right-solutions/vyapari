# This migration comes from vyapari (originally 20170000000203)
class CreateContacts < ActiveRecord::Migration
  def change
    create_table(:contacts) do |t|

      t.string :name, limit: 256
      t.string :designation, :null => true, :limit=>56
      t.string :email, :null => false
      t.string :phone, :null => true, :limit=>24
      t.string :landline, :null => true, :limit=>24
      t.string :fax, :null => true, :limit=>24
      
      t.integer :contactable_id
      t.string  :contactable_type

      t.timestamps
    end
    
    add_index :contacts, :name
    add_index(:contacts, [ :contactable_id, :contactable_type ])
  end
end
    
