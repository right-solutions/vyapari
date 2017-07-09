require 'spec_helper'

RSpec.describe Category, type: :model do

  let(:mens_wear) {FactoryGirl.create(:category, name: "Mens Wear")}
  let(:lifebuoy) {FactoryGirl.create(:category, name: "Lifebuoy Soap")}
  let(:lux) {FactoryGirl.create(:category, name: "Lux Soap")}

  let(:published_category) {FactoryGirl.create(:published_category, name: "Published Category")}
  let(:unpublished_category) {FactoryGirl.create(:unpublished_category, name: "Un Published Category")}
  let(:removed_category) {FactoryGirl.create(:removed_category, name: "Removed Category")}

  let(:featured_category) {FactoryGirl.create(:featured_category, name: "Featured Category")}

  context "Factory" do
    it "should validate all the factories" do
      expect(FactoryGirl.build(:category).valid?).to be true
      
      published_category = FactoryGirl.build(:published_category)
      expect(published_category.valid?).to be true
      expect(published_category.status).to match("published")

      unpublished_category = FactoryGirl.build(:unpublished_category)
      expect(unpublished_category.valid?).to be true
      expect(unpublished_category.status).to match("unpublished")

      removed_category = FactoryGirl.build(:removed_category)
      expect(removed_category.valid?).to be true
      expect(removed_category.status).to match("removed")

      featured_category = FactoryGirl.build(:featured_category)
      expect(featured_category.valid?).to be true
      expect(featured_category.featured).to be_truthy

      unfeatured_category = FactoryGirl.build(:unfeatured_category)
      expect(unfeatured_category.valid?).to be true
      expect(unfeatured_category.featured).to be_falsy
    end
  end

  context "Validations" do
    it { should validate_presence_of :name }
    it { should allow_value('Coca Cola').for(:name )}
    it { should_not allow_value('CC').for(:name )}
    it { should_not allow_value("x"*257).for(:name )}

    it { should validate_inclusion_of(:status).in_array(Category::STATUS.keys)  }
    it { should validate_numericality_of(:priority) }
  end

  context "Associations" do
    it { should belong_to(:parent) }
    it { should belong_to(:top_parent) }
    it { should have_many(:sub_categories) }
    it { should have_one(:category_image) }
    it { should have_many(:products) }
  end

  context "Class Methods" do
    it "search" do
      arr = [mens_wear, lifebuoy, lux]
      expect(Category.search("Mens Wear")).to match_array([mens_wear])
      expect(Category.search("Lifebuoy Soap")).to match_array([lifebuoy])
      expect(Category.search("Lux Soap")).to match_array([lux])
      expect(Category.search("Soap")).to match_array([lifebuoy, lux])
    end

    it "scope unpublished" do
      [mens_wear, lifebuoy, lux, published_category, removed_category]
      expect(Category.unpublished.all).to match_array [mens_wear, lifebuoy, lux]
    end

    it "scope published" do
      [mens_wear, lifebuoy, lux, published_category, removed_category]
      expect(Category.published.all).to match_array [published_category]
    end

    it "scope removed" do
      [mens_wear, lifebuoy, lux, published_category, removed_category]
      expect(Category.removed.all).to match_array [removed_category]
    end

    it "scope status" do
      [mens_wear, lifebuoy, lux, published_category, removed_category]
      expect(Category.status(Category::UNPUBLISHED)).to match_array [mens_wear, lifebuoy, lux]
      expect(Category.status(Category::PUBLISHED)).to match_array [published_category]
      expect(Category.status(Category::REMOVED)).to match_array [removed_category]
    end

    it "scope featured" do
      expect(Category.featured(false)).to match_array [mens_wear, lifebuoy, lux]
      expect(Category.featured(true)).to match_array [featured_category]
    end

    context "Import Methods" do

      it "save_row_data" do
        skip
      end

    end
  end

  context "Instance Methods" do

    it "display_name" do
      expect(mens_wear.display_name).to match("Mens Wear")
    end

    it "slug" do
      expect(mens_wear.slug).to match(mens_wear.name.parameterize)
    end

    it "to_param" do
      expect(mens_wear.to_param).to match("#{mens_wear.id}-#{mens_wear.slug}")
    end

    it "publish!" do
      c = FactoryGirl.create(:unpublished_category)
      expect(c.status).to match "unpublished"
      c.publish!
      expect(c.status).to match "published"
    end

    it "unpublish!" do
      c = FactoryGirl.create(:published_category)
      expect(c.status).to match "published"
      c.unpublish!
      expect(c.status).to match "unpublished"
    end

    it "remove!" do
      c = FactoryGirl.create(:published_category)
      expect(c.status).to match "published"
      c.remove!
      expect(c.status).to match "removed"
    end

    it "can_be_published?, can_be_unpublished? & can_be_removed?" do
      c = FactoryGirl.create(:unpublished_category)
      expect(c.can_be_published?).to be_truthy
      expect(c.can_be_unpublished?).to be_falsy
      expect(c.can_be_removed?).to be_truthy

      c.publish!
      expect(c.can_be_published?).to be_falsy
      expect(c.can_be_unpublished?).to be_truthy
      expect(c.can_be_removed?).to be_truthy

      c.remove!
      expect(c.can_be_published?).to be_truthy
      expect(c.can_be_unpublished?).to be_truthy
      expect(c.can_be_removed?).to be_falsy
    end

    it "can_be_edited?" do
      c = FactoryGirl.create(:published_category)
      expect(c.can_be_edited?).to be_truthy

      c = FactoryGirl.create(:unpublished_category)
      expect(c.can_be_edited?).to be_truthy

      c = FactoryGirl.create(:removed_category)
      expect(c.can_be_edited?).to be_falsy
    end

    it "can_be_deleted?" do
      c = FactoryGirl.create(:published_category)
      expect(c.can_be_deleted?).to be_falsy

      c = FactoryGirl.create(:unpublished_category)
      expect(c.can_be_deleted?).to be_falsy

      c = FactoryGirl.create(:removed_category)
      expect(c.can_be_deleted?).to be_truthy
    end
  end

end