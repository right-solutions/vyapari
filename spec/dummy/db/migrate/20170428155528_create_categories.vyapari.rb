# This migration comes from vyapari (originally 20170000000211)
class CreateCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :categories do |t|
      
      t.string :name, :null => false, limit: 128
      t.string :one_liner, limit: 128
      
      t.references :parent, references: :category
      t.references :top_parent, references: :category
      
      t.string :status, :null => false, :default=>"unpublished", :limit=>16
      t.boolean :featured, default: false

      t.integer :priority, default: 1000

      t.timestamps null: false
    end

    add_index :categories, :status
    
  end
end
