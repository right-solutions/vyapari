class Country < Vyapari::ApplicationRecord

  DELETE_MESSAGE = "Cannot delete the country. You should first remove all the cities and exchange rates associated with this country."

  # Validations
  validates :name, presence: true, length: {minimum: 2, maximum: 250}, allow_blank: false
  validates :code, presence: true, uniqueness: true, length: {minimum: 2, maximum: 32}, allow_blank: false

  # Associations
  has_many :regions
  has_many :exchange_rates
  
  # ------------------
  # Class Methods
  # ------------------

  # return an active record relation object with the search query in its where clause
  # Return the ActiveRecord::Relation object
  # == Examples
  #   >>> obj.search(query)
  #   => ActiveRecord::Relation object
  scope :search, lambda {|query| where("LOWER(countries.name) LIKE LOWER('%#{query}%')")}

  # ------------------
  # Instance Methods
  # ------------------

  def display_name
    self.name_was
  end

  def can_be_edited?
    true
  end

  def can_be_deleted?
    if self.regions.any? || self.exchange_rates.any?
      self.errors.add(:base, DELETE_MESSAGE) 
      return false
    else
      return true
    end
  end

end
