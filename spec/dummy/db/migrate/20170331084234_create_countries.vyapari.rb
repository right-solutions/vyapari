# This migration comes from vyapari (originally 20140402113214)
class CreateCountries < ActiveRecord::Migration
  def change
    create_table(:countries) do |t|

      t.string :name, limit: 128
      t.string :code, limit: 16

      t.timestamps
    end
    add_index :countries, :code, :unique => true
  end
end
