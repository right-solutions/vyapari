class Brand < Vyapari::ApplicationRecord

  # Constants
  PUBLISHED = "published"
  UNPUBLISHED = "unpublished"
  REMOVED = "removed"
  
  STATUS_HASH = {"Published" => PUBLISHED, "Unpublished" => UNPUBLISHED, "Removed" => REMOVED}
  STATUS_HASH_REVERSE = {PUBLISHED => "Published", UNPUBLISHED => "Unpublished", REMOVED => "Removed"}

  FEATURED_HASH = {"Featured" => true, "Non Featured" => false}
  FEATURED_HASH_REVERSE = {true => "Featured", false => "Non Featured"}

  # Validations
  validates :name, :presence=> true
  validates :status, :presence=> true, :inclusion => {:in => STATUS_HASH_REVERSE.keys, :presence_of => :status, :message => "%{value} is not a valid status" }

  # Associations
  has_one :brand_image, :as => :imageable, :dependent => :destroy, :class_name => "Image::BrandImage"

  # ------------------
  # Class Methods
  # ------------------

  # Scopes

  # return an published record relation object with the search query in its where clause
  # Return the ActiveRecord::Relation object
  # == Examples
  #   >>> brand.search(query)
  #   => ActiveRecord::Relation object
  scope :search, lambda { |query| where("LOWER(name) LIKE LOWER('%#{query}%')")
                        }

  scope :status, lambda { |status| where("LOWER(status)='#{status}'") }
  scope :featured, lambda { |val| where(featured: val) }

  scope :published, -> { where(status: PUBLISHED) }
  scope :unpublished, -> { where(status: UNPUBLISHED) }
  scope :removed, -> { where(status: REMOVED) }

  scope :this_month, lambda { where("created_at >= ? AND created_at <= ?", Time.zone.now.beginning_of_month, Time.zone.now.end_of_month) }
  
  # * Return true if the brand is published, else false.
  # == Examples
  #   >>> brand.published?
  #   => true
  def published?
    (status == PUBLISHED)
  end

  # change the status to :published
  # Return the status
  # == Examples
  #   >>> brand.publish!
  #   => "published"
  def publish!
    self.update_attribute(:status, PUBLISHED)
  end

  # * Return true if the brand is unpublished, else false.
  # == Examples
  #   >>> brand.unpublished?
  #   => true
  def unpublished?
    (status == UNPUBLISHED)
  end

  # change the status to :unpublished
  # Return the status
  # == Examples
  #   >>> brand.unpublish!
  #   => "unpublished"
  def unpublish!
    self.update_attributes(status: UNPUBLISHED, featured: false)
  end

  # * Return true if the brand is removed, else false.
  # == Examples
  #   >>> brand.removed?
  #   => true
  def removed?
    (status == REMOVED)
  end

  # change the status to :removed
  # Return the status
  # == Examples
  #   >>> brand.remove!
  #   => "removed"
  def remove!
    self.update_attributes(status: REMOVED, featured: false)
  end

  # TODO
  def can_be_deleted?
    #if self.jobs.any?
    #  self.errors.add(:base, DELETE_MESSAGE) 
    #  return false
    #else
    #  return true
    #end
    return true
  end

  def display_name
    self.name
  end

  def default_image_url(size="medium")
    "/assets/defaults/brand-#{size}.png"
  end
  
end
