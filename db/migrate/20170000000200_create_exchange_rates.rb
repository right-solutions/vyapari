class CreateExchangeRates < ActiveRecord::Migration
  def change
    create_table(:exchange_rates) do |t|

      t.string :base_currency, limit: 4
      t.string :counter_currency, limit: 4
      t.decimal :value, :precision => 16, :scale => 4
      t.datetime :effective_date

      t.timestamps
    end

    add_reference :exchange_rates, :country
    add_index :exchange_rates, [:base_currency, :counter_currency]
    
  end
end
