class Supplier < Vyapari::ApplicationRecord

  # Validations
  validates :name, presence: true, length: {minimum: 2, maximum: 250}, allow_blank: false
  validates :code, presence: true, uniqueness: true, length: {minimum: 2, maximum: 24}, allow_blank: false
  validates :address, presence: true, length: {minimum: 3, maximum: 1024}, allow_blank: true
  validates :city, presence: true, length: {minimum: 2, maximum: 56}, allow_blank: true
  validates :country, presence: true
  
  # Associations
  belongs_to :country
  has_many :products
  
  # ------------------
  # Class Methods
  # ------------------

  # return an active record relation object with the search query in its where clause
  # Return the ActiveRecord::Relation object
  # == Examples
  #   >>> obj.search(query)
  #   => ActiveRecord::Relation object
  scope :search, lambda {|query| joins(:country).where("LOWER(name) LIKE LOWER('%#{query}%') OR 
                                                        LOWER(code) LIKE LOWER('%#{query}%') OR 
                                                        LOWER(address) LIKE LOWER('%#{query}%') OR 
                                                        LOWER(city) LIKE LOWER('%#{query}%')")}

  
  def self.save_row_data(row)

    row.headers.each{ |cell| row[cell] = row[cell].to_s.strip }

    return if row[:name].blank?

    supplier = Supplier.find_by_code(row[:code]) || Supplier.new
    
    supplier.name = row[:name]
    supplier.code = row[:code]
    supplier.address = row[:address]
    supplier.city = row[:city]
    supplier.country = Country.find_by_code(row[:country]) || Country.find_by_name(row[:country])
    
    # Initializing error hash for displaying all errors altogether
    error_object = Kuppayam::Importer::ErrorHash.new

    if supplier.valid?
      supplier.save!
    else
      summary = "Error while saving supplier: #{supplier.name}"
      details = "Error! #{supplier.errors.full_messages.to_sentence}"
      error_object.errors << { summary: summary, details: details }
    end
    return error_object
  end

  # ------------------
  # Instance Methods
  # ------------------

  def display_name
    self.country ? "#{self.code_was}-#{self.name_was}, #{self.country.name}" : "#{self.code_was}-#{self.name_was}"
  end

  def can_be_edited?
    true
  end

  def can_be_deleted?
    # if self.products.any?
    #   #self.errors.add(:base, DELETE_MESSAGE) 
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
