class Region < Vyapari::ApplicationRecord

  # Validations
  validates :name, presence: true, length: {minimum: 2, maximum: 128}, allow_blank: false
  validates :code, presence: true, uniqueness: true, length: {minimum: 2, maximum: 16}, allow_blank: false
  validates :country, presence: true
  
  # Associations
  belongs_to :country
  has_many :stores
  
  # ------------------
  # Class Methods
  # ------------------

  # return an active record relation object with the search query in its where clause
  # Return the ActiveRecord::Relation object
  # == Examples
  #   >>> obj.search(query)
  #   => ActiveRecord::Relation object
  scope :search, lambda {|query| joins(:country).where("LOWER(regions.name) LIKE LOWER('%#{query}%') OR LOWER(countries.name) LIKE LOWER('%#{query}%')")}

  # Import Methods
  # --------------

  def self.save_row_data(row)

    row.headers.each{ |cell| row[cell] = row[cell].to_s.strip }

    return if row[:name].blank?

    region = Region.find_by_code(row[:code]) || Region.new
    region.name = row[:name]
    region.code = row[:code]
    region.country = Country.find_by_code(row[:country]) || Country.find_by_name(row[:country])

    # Initializing error hash for displaying all errors altogether
    error_object = Kuppayam::Importer::ErrorHash.new

    if region.valid?
      region.save!
    else
      summary = "Error while saving region: #{region.name}"
      details = "Error! #{region.errors.full_messages.to_sentence}"
      error_object.errors << { summary: summary, details: details }
    end

    return error_object
  end

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
    if self.stores.any?
      return false
    else
      return true
    end
  end

end
