class Category < Vyapari::ApplicationRecord

  # Constants
  PUBLISHED = "published"
  UNPUBLISHED = "unpublished"
  REMOVED = "removed"
  
  STATUS_HASH = {"Published" => PUBLISHED, "Unpublished" => UNPUBLISHED, "Removed" => REMOVED}
  STATUS_HASH_REVERSE = {PUBLISHED => "Published", UNPUBLISHED => "Unpublished", REMOVED => "Removed"}

  FEATURED_HASH = {"Featured" => true, "Non Featured" => false}
  FEATURED_HASH_REVERSE = {true => "Featured", false => "Non Featured"}

  # Callbacks
  before_validation :update_permalink

	# Validations
  extend PoodleValidators
  validates :name, presence: true
  validates :one_liner, presence: false
  validates :status, :presence=> true, :inclusion => {:in => STATUS_HASH_REVERSE.keys, :presence_of => :status, :message => "%{value} is not a valid status" }

  # Associations
  has_many :products
  belongs_to :parent, :class_name => 'Category', optional: true
  has_many :sub_categories, :foreign_key => "parent_id", :class_name => "Category" 
  has_one :category_image, :as => :imageable, :dependent => :destroy, :class_name => "Image::CategoryImage"

  # return an active record relation object with the search query in its where clause
  # Return the ActiveRecord::Relation object
  # == Examples
  #   >>> object.search(query)
  #   => ActiveRecord::Relation object
  scope :search, lambda {|query| where("LOWER(name) LIKE LOWER('%#{query}%') OR\
                                        LOWER(permalink) LIKE LOWER('%#{query}%') OR\
                                        LOWER(one_liner) LIKE LOWER('%#{query}%') OR\
                                        LOWER(description) LIKE LOWER('%#{query}%')")
                        }

  scope :status, lambda { |status| where("LOWER(status)='#{status}'") }
  scope :featured, lambda { |val| where(featured: val) }

  scope :published, -> { where(status: PUBLISHED) }
  scope :unpublished, -> { where(status: UNPUBLISHED) }
  scope :removed, -> { where(status: REMOVED) }
  
  # ------------------
  # Instance variables
  # ------------------

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

  def default_image_url(size="medium")
    "/assets/defaults/category-#{size}.png"
  end

  def display_name
    self.name
  end

  protected
  
  def update_permalink
    self.permalink = "#{self.id}-#{name.parameterize}"
  end

end
