class Contact < Vyapari::ApplicationRecord

  # Validations
  validates :name, presence: true, length: {minimum: 2, maximum: 250}, allow_blank: false
  validates :email, length: {maximum: 128}, allow_blank: true
  validates :phone, length: {maximum: 128}, allow_blank: true

  # Associations
  belongs_to :contactable, :polymorphic => true
  
  # ------------------
  # Class Methods
  # ------------------

  # return an active record relation object with the search query in its where clause
  # Return the ActiveRecord::Relation object
  # == Examples
  #   >>> obj.search(query)
  #   => ActiveRecord::Relation object
  scope :search, lambda {|query| where("LOWER(contacts.name) LIKE LOWER('%#{query}%') OR
                                        LOWER(contacts.email) LIKE LOWER('%#{query}%') OR
                                        LOWER(contacts.phone) LIKE LOWER('%#{query}%') OR
                                        LOWER(contacts.landline) LIKE LOWER('%#{query}%') OR
                                        LOWER(contacts.fax) LIKE LOWER('%#{query}%') OR
                                        LOWER(contacts.designation) LIKE LOWER('%#{query}%')
                        ")}

  # Import Methods
  # --------------
  
  # TODO - this is yet to be done
  def self.save_row_data(row)

    row.headers.each{ |cell| row[cell] = row[cell].to_s.strip }

    return if row[:name].blank?

    country = Contact.find_by_code(row[:code]) || Contact.new
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
    false
  end

end
