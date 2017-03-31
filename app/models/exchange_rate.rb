class ExchangeRate < Vyapari::ApplicationRecord

  # Validations
  validates :currency_name, presence: true, length: {minimum: 2, maximum: 4}, allow_blank: false
  validates :value, presence: true
  validates :effective_date, presence: true

  # Associations
  belongs_to :country
  
  # ------------------
  # Class Methods
  # ------------------

  # return an active record relation object with the search query in its where clause
  # Return the ActiveRecord::Relation object
  # == Examples
  #   >>> obj.search(query)
  #   => ActiveRecord::Relation object
  scope :search, lambda {|query| joins(:country).where("LOWER(exchange_rates.currency_name) LIKE LOWER('%#{query}%') OR LOWER(countries.name) LIKE LOWER('%#{query}%')")}

  # ------------------
  # Instance Methods
  # ------------------

  def display_name
    "#{self.currency_name_was}, #{self.country.try(:name)}"
  end

  def can_be_edited?
    return true
  end

  def can_be_deleted?
    return true
  end

end
