class Region < Vyapari::ApplicationRecord

  DELETE_MESSAGE = "Cannot delete this Region. You should first delete all the dependant data like Company Cities, Jobs, Budgets etc tagged with this Region"

  # Validations
  validates :name, presence: true, length: {minimum: 2, maximum: 250}, allow_blank: false
  validates :code, presence: true, uniqueness: true, length: {minimum: 2, maximum: 32}, allow_blank: false
  validates :country, presence: true
  
  # Associations
  belongs_to :country
  # has_many :stores
  
  # ------------------
  # Class Methods
  # ------------------

  # return an active record relation object with the search query in its where clause
  # Return the ActiveRecord::Relation object
  # == Examples
  #   >>> obj.search(query)
  #   => ActiveRecord::Relation object
  scope :search, lambda {|query| joins(:country).where("LOWER(cities.name) LIKE LOWER('%#{query}%') OR LOWER(countries.name) LIKE LOWER('%#{query}%')")}

  # ------------------
  # Instance Methods
  # ------------------

  def display_name
    if self.country
      "#{self.name_was}, #{self.country.name}"
    else
      self.name
    end
  end

  def can_be_edited?
    true
  end

  def can_be_deleted?
    # if self.stores.any?
    #   self.errors.add(:base, DELETE_MESSAGE) 
    #   return false
    # else
    #   return true
    # end
    return true
  end

  def report_heading
    rh = []
    rh << self.company.try(:name) if self.company.name
    rh << self.display_name
    rh.join(", ")
  end

end
