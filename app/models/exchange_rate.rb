class ExchangeRate < Vyapari::ApplicationRecord

  # Validations
  validates :base_currency, presence: true, length: {minimum: 2, maximum: 6}, allow_blank: false
  validates :counter_currency, presence: true, length: {minimum: 2, maximum: 6}, allow_blank: false
  validates :value, presence: true
  validates :effective_date, presence: true

  # ------------------
  # Class Methods
  # ------------------

  # return an active record relation object with the search query in its where clause
  # Return the ActiveRecord::Relation object
  # == Examples
  #   >>> obj.search(query)
  #   => ActiveRecord::Relation object
  scope :search, lambda {|query| where("LOWER(base_currency) LIKE LOWER('%#{query}%') OR LOWER(counter_currency) LIKE LOWER('%#{query}%')")}

  def self.save_row_data(row)

    row.headers.each{ |cell| row[cell] = row[cell].to_s.strip }

    return if row[:base_currency].blank?

    exchange_rate = ExchangeRate.where("base_currency = ? AND counter_currency = ?", row[:base_currency], row[:counter_currency]).first || ExchangeRate.new
    
    exchange_rate.base_currency = row[:base_currency]
    exchange_rate.counter_currency = row[:counter_currency]
    exchange_rate.value = row[:value]
    exchange_rate.effective_date = row[:effective_date]
    
    # Initializing error hash for displaying all errors altogether
    error_object = Kuppayam::Importer::ErrorHash.new

    if exchange_rate.valid?
      exchange_rate.save!
    else
      summary = "Error while saving exchange_rate: #{exchange_rate.name}"
      details = "Error! #{exchange_rate.errors.full_messages.to_sentence}"
      error_object.errors << { summary: summary, details: details }
    end

    return error_object
  end

  # ------------------
  # Instance Methods
  # ------------------

  def display_name
    "#{self.base_currency_was} to #{self.counter_currency_was}"
  end

  def can_be_edited?
    return true
  end

  def can_be_deleted?
    return true
  end

end
