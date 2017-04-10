# This migration comes from vyapari (originally 20170000000212)
class CreateProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :products do |t|
      
      t.string :name, :null => false, limit: 128
      t.string :one_liner
      t.text   :description

      t.string :ean_sku
      t.string :reference_number
      
      t.references :brand
      t.references :category
      t.references :top_category

      t.decimal :purchased_price, :precision => 16, :scale => 2
      t.decimal :landed_price, :precision => 16, :scale => 2
      t.decimal :selling_price, :precision => 16, :scale => 2
      t.decimal :retail_price, :precision => 16, :scale => 2

      t.string :status, :null => false, :default=>"unpublished", :limit=>16
      t.boolean :featured, default: false

      t.timestamps null: false
    end

    add_index :products, :status
  end
end
