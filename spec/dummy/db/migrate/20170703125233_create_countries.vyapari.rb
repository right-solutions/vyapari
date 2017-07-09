# This migration comes from vyapari (originally 20170000000201)
class CreateCountries < ActiveRecord::Migration[5.0]
  def change
    create_table(:countries) do |t|

      t.string :name, limit: 128
      t.string :code, limit: 16

      t.timestamps
    end
    add_index :countries, :code, :unique => true
  end
end
