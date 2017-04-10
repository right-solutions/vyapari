require 'spec_helper'

RSpec.describe Category, type: :model do

  let(:mens_wear) {FactoryGirl.create(:category, name: "Mens Wear")}
  let(:lifebuoy) {FactoryGirl.create(:category, name: "Lifebuoy Soap")}
  let(:lux) {FactoryGirl.create(:category, name: "Lux Soap")}
  let(:horlicks) {FactoryGirl.create(:category, name: "Horlicks")}

  let(:published_category) {FactoryGirl.create(:published_category, name: "Published Category")}
  let(:unpublished_category) {FactoryGirl.create(:unpublished_category, name: "Un Published Category")}
  let(:removed_category) {FactoryGirl.create(:removed_category, name: "Removed Category")}

  let(:featured_category) {FactoryGirl.create(:featured_category, name: "Featured Category")}

  context "Factory" do
    it "should validate all the factories" do
      expect(FactoryGirl.build(:category).valid?).to be true
      expect(FactoryGirl.build(:published_category).valid?).to be true
      expect(FactoryGirl.build(:unpublished_category).valid?).to be true
      expect(FactoryGirl.build(:removed_category).valid?).to be true
      expect(FactoryGirl.build(:featured_category).valid?).to be true
      expect(FactoryGirl.build(:unfeatured_category).valid?).to be true
    end
    
    it "should set right status for all factories" do
      expect(FactoryGirl.build(:category).status).to match "unpublished"
      expect(FactoryGirl.build(:published_category).status).to match "published"
      expect(FactoryGirl.build(:unpublished_category).status).to match "unpublished"
      expect(FactoryGirl.build(:removed_category).status).to match "removed"
      expect(FactoryGirl.build(:featured_category).status).to match "published"
      expect(FactoryGirl.build(:unfeatured_category).status).to match "published"
    end

    it "should set featured false for all factories by default" do
      expect(FactoryGirl.build(:category).featured).to match false
    end
  end

  context "Validations" do
    it { should validate_presence_of :name }
    it { should allow_value('Coca Cola').for(:name )}
    it { should_not allow_value('CC').for(:name )}
    it { should_not allow_value("x"*257).for(:name )}

    it { should validate_inclusion_of(:status).in_array(Category::STATUS.values)  }
  end

  context "Associations" do
    it { should have_one(:category_image) }
    it { should have_many(:products) }
  end

  context "Class Methods" do
    it "search" do
      arr = [tata_salt, lifebuoy, horlicks]
      expect(Category.search("Tata Salt")).to match_array([tata_salt])
      expect(Category.search("Lifebuoy Soap")).to match_array([lifebuoy])
      expect(Category.search("Horlicks")).to match_array([horlicks])
      expect(Category.search("Soap")).to match_array([lifebuoy, lux])
    end

    it "scope unpublished" do
      expect(Category.unpublished.all).to match_array [tata_salt, lifebuoy, horlicks]
    end

    it "scope published" do
      published_category
      expect(Category.published.all).to match_array [published_category]
    end

    it "scope removed" do
      removed_category
      expect(Category.removed.all).to match_array [removed_category]
    end

    it "scope status" do
      published_category
      removed_category
      expect(Category.status(Category::UNPUBLISHED)).to match_array [tata_salt, lifebuoy, horlicks]
      expect(Category.status(Category::PUBLISHED)).to match_array [published_category]
      expect(Category.status(Category::REMOVED)).to match_array [removed_category]
    end

    it "scope featured" do
      expect(Category.featured(false)).to match_array [tata_salt, lifebuoy, horlicks]
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
      expect(tata_salt.display_name).to match("Tata Salt")
    end

    it "slug" do
      expect(tata_salt.slug).to match(tata_salt.name.parameterize)
    end

    it "to_param" do
      expect(tata_salt.to_param).to match("#{tata_salt.id}-#{tata_salt.slug}")
    end

    it "publish!" do
      b = FactoryGirl.create(:unpublished_category)
      expect(b.status).to match "unpublished"
      b.publish!
      expect(b.status).to match "published"
    end

    it "unpublish!" do
      b = FactoryGirl.create(:published_category)
      expect(b.status).to match "published"
      b.unpublish!
      expect(b.status).to match "unpublished"
    end

    it "remove!" do
      b = FactoryGirl.create(:published_category)
      expect(b.status).to match "published"
      b.remove!
      expect(b.status).to match "removed"
    end

    it "can_be_published?, can_be_unpublished? & can_be_removed?" do
      b = FactoryGirl.create(:unpublished_category)
      expect(b.can_be_published?).to be_truthy
      expect(b.can_be_unpublished?).to be_falsy
      expect(b.can_be_removed?).to be_truthy

      b.publish!
      expect(b.can_be_published?).to be_falsy
      expect(b.can_be_unpublished?).to be_truthy
      expect(b.can_be_removed?).to be_truthy

      b.remove!
      expect(b.can_be_published?).to be_truthy
      expect(b.can_be_unpublished?).to be_truthy
      expect(b.can_be_removed?).to be_falsy
    end

    it "can_be_edited?" do
      b = FactoryGirl.create(:unpublished_category)
      expect(b.can_be_edited?).to be_truthy
    end

    it "can_be_deleted?" do
      skip
    end
  end

end