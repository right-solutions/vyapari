class Country < Vyapari::ApplicationRecord

  # Validations
  validates :name, presence: true, length: {minimum: 2, maximum: 250}, allow_blank: false
  validates :code, presence: true, uniqueness: true, length: {minimum: 2, maximum: 32}, allow_blank: false

  # Associations
  has_many :regions
  has_many :stores
  
  # ------------------
  # Class Methods
  # ------------------

  # return an active record relation object with the search query in its where clause
  # Return the ActiveRecord::Relation object
  # == Examples
  #   >>> obj.search(query)
  #   => ActiveRecord::Relation object
  scope :search, lambda {|query| where("LOWER(countries.name) LIKE LOWER('%#{query}%')")}

  def self.save_row_data(row)

    row.headers.each{ |cell| row[cell] = row[cell].to_s.strip }

    return if row[:name].blank?

    country = Country.find_by_code(row[:code]) || Country.new
    country.name = row[:name]
    country.code = row[:code]

    # Initializing error hash for displaying all errors altogether
    error_object = Kuppayam::Importer::ErrorHash.new

    if country.valid?
      country.save!
    else
      summary = "Error while saving country: #{country.name}"
      details = "Error! #{country.errors.full_messages.to_sentence}"
      error_object.errors << { summary: summary, details: details }
    end

    return error_object
  end

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
    if self.regions.any?
      #self.errors.add(:base, DELETE_MESSAGE) 
      return false
    else
      return true
    end
  end

end
