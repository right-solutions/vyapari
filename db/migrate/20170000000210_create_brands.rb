class CreateBrands < ActiveRecord::Migration[5.0]
  def change
    create_table :brands do |t|

      t.string :name, :null => false, limit: 512
      t.boolean :featured, default: false
      t.string :status, :null => false, :default=>"unpublished", :limit=>16
      t.integer :priority
      t.timestamps null: false
    end

    add_index :brands, :status
  end
end