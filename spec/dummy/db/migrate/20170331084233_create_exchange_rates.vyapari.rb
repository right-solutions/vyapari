# This migration comes from vyapari (originally 20140402113213)
class CreateExchangeRates < ActiveRecord::Migration
  def change
    create_table(:exchange_rates) do |t|

      t.string :currency_name, limit: 4
      t.decimal :value, :precision => 16, :scale => 4
      t.datetime :effective_date

      t.timestamps
    end

    add_reference :exchange_rates, :country
    add_index :exchange_rates, [:currency_name, :country_id]
    
  end
end
