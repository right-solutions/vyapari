class Category < Vyapari::ApplicationRecord

  # Constants
  PUBLISHED = "published"
  UNPUBLISHED = "unpublished"
  REMOVED = "removed"
  
  STATUS = {PUBLISHED => "Published", UNPUBLISHED => "Unpublished", REMOVED => "Removed"}
  STATUS_REVERSE = {"Published" => PUBLISHED, "Unpublished" => UNPUBLISHED, "Removed" => REMOVED}

  FEATURED_HASH = {true => "Featured", false => "Non Featured"}
  FEATURED_HASH_REVERSE = {"Featured" => true, "Non Featured" => false}

  # Validations
  validates :name, presence: true, length: {minimum: 3, maximum: 250}
  validates :priority, numericality: true
  validates :one_liner, presence: false
  validates :status, :presence=> true, :inclusion => {:in => STATUS.keys, :presence_of => :status, :message => "%{value} is not a valid status" }

  # Associations
  has_many :products
  belongs_to :parent, :class_name => 'Category', optional: true
  belongs_to :top_parent, :class_name => 'Category', optional: true
  has_many :sub_categories, :foreign_key => "parent_id", :class_name => "Category" 
  has_one :category_image, :as => :imageable, :dependent => :destroy, :class_name => "Image::CategoryImage"

  # return an active record relation object with the search query in its where clause
  # Return the ActiveRecord::Relation object
  # == Examples
  #   >>> object.search(query)
  #   => ActiveRecord::Relation object
  scope :search, lambda {|query| where("LOWER(name) LIKE LOWER('%#{query}%') OR\
                                        LOWER(one_liner) LIKE LOWER('%#{query}%')")}

  scope :status, lambda { |status| where("LOWER(status)='#{status}'") }
  scope :featured, lambda { |val| where(featured: val) }

  scope :published, -> { where(status: PUBLISHED) }
  scope :unpublished, -> { where(status: UNPUBLISHED) }
  scope :removed, -> { where(status: REMOVED) }
  
  def self.save_row_data(row)

    row.headers.each{ |cell| row[cell] = row[cell].to_s.strip }

    return if row[:name].blank?

    category = Category.find_by_name(row[:name]) || Category.new
    
    category.name = row[:name]
    category.one_liner = row[:one_liner]
    category.parent = Category.find_by_name(row[:parent])
    category.top_parent = category.parent.top_parent if category.parent
    
    category.featured = row[:featured]
    category.status = row[:status]
    category.priority = row[:priority]
    
    # Initializing error hash for displaying all errors altogether
    error_object = Kuppayam::Importer::ErrorHash.new

    if category.valid?
      category.save!
    else
      summary = "Error while saving category: #{category.name}"
      details = "Error! #{category.errors.full_messages.to_sentence}"
      error_object.errors << { summary: summary, details: details }
    end
    return error_object
  end

  # ------------------
  # Instance variables
  # ------------------

  def display_name
    self.name
  end
  
  def slug
    self.name.parameterize
  end

  def to_param
    "#{id}-#{slug}"
  end

  # * Return true if the category is published, else false.
  # == Examples
  #   >>> category.published?
  #   => true
  def published?
    (status == PUBLISHED)
  end

  # change the status to :published
  # Return the status
  # == Examples
  #   >>> category.publish!
  #   => "published"
  def publish!
    self.update_attribute(:status, PUBLISHED)
  end

  # * Return true if the category is unpublished, else false.
  # == Examples
  #   >>> category.unpublished?
  #   => true
  def unpublished?
    (status == UNPUBLISHED)
  end

  # change the status to :unpublished
  # Return the status
  # == Examples
  #   >>> category.unpublish!
  #   => "unpublished"
  def unpublish!
    self.update_attribute(:status, UNPUBLISHED)
  end

  # * Return true if the category is removed, else false.
  # == Examples
  #   >>> category.removed?
  #   => true
  def removed?
    (status == REMOVED)
  end

  # change the status to :removed
  # Return the status
  # == Examples
  #   >>> category.remove!
  #   => "removed"
  def remove!
    self.update_attribute(:status, REMOVED)
  end

  def can_be_published?
    unpublished? or removed?
  end

  def can_be_unpublished?
    published? or removed?
  end

  def can_be_removed?
    published? or unpublished?
  end

  def can_be_edited?
    published? or unpublished?
  end

  def can_be_deleted?
    removed?
  end

end
