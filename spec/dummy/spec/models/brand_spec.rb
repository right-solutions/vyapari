require 'spec_helper'

RSpec.describe Brand, type: :model do

  let(:brand) {FactoryGirl.build(:brand)}
  let(:tata_salt) {FactoryGirl.create(:brand, name: "Tata Salt")}
  let(:lifebuoy) {FactoryGirl.create(:brand, name: "Lifebuoy Soap")}
  let(:lux) {FactoryGirl.create(:brand, name: "Lux Soap")}
  let(:horlicks) {FactoryGirl.create(:brand, name: "Horlicks")}

  let(:published_brand) {FactoryGirl.create(:published_brand, name: "Published Brand")}
  let(:unpublished_brand) {FactoryGirl.create(:unpublished_brand, name: "Un Published Brand")}
  let(:removed_brand) {FactoryGirl.create(:removed_brand, name: "Removed Brand")}

  let(:featured_brand) {FactoryGirl.create(:featured_brand, name: "Featured Brand")}

  context "Factory" do
    it "should validate all the factories" do
      expect(FactoryGirl.build(:brand).valid?).to be true
      expect(FactoryGirl.build(:published_brand).valid?).to be true
      expect(FactoryGirl.build(:unpublished_brand).valid?).to be true
      expect(FactoryGirl.build(:removed_brand).valid?).to be true
      expect(FactoryGirl.build(:featured_brand).valid?).to be true
      expect(FactoryGirl.build(:unfeatured_brand).valid?).to be true
    end
    
    it "should set right status for all factories" do
      expect(FactoryGirl.build(:brand).status).to match "unpublished"
      expect(FactoryGirl.build(:published_brand).status).to match "published"
      expect(FactoryGirl.build(:unpublished_brand).status).to match "unpublished"
      expect(FactoryGirl.build(:removed_brand).status).to match "removed"
      expect(FactoryGirl.build(:featured_brand).status).to match "published"
      expect(FactoryGirl.build(:unfeatured_brand).status).to match "published"
    end

    it "should set featured false for all factories by default" do
      expect(FactoryGirl.build(:brand).featured).to match false
    end
  end

  context "Validations" do
    it { should validate_presence_of :name }
    it { should allow_value('Coca Cola').for(:name )}
    it { should_not allow_value('CC').for(:name )}
    it { should_not allow_value("x"*257).for(:name )}

    it { should validate_inclusion_of(:status).in_array(Brand::STATUS.values)  }
  end

  context "Associations" do
    it { should have_one(:brand_image) }
    it { should have_many(:products) }
  end

  context "Class Methods" do
    it "search" do
      arr = [tata_salt, lifebuoy, horlicks]
      expect(Brand.search("Tata Salt")).to match_array([tata_salt])
      expect(Brand.search("Lifebuoy Soap")).to match_array([lifebuoy])
      expect(Brand.search("Horlicks")).to match_array([horlicks])
      expect(Brand.search("Soap")).to match_array([lifebuoy, lux])
    end

    it "scope unpublished" do
      expect(Brand.unpublished.all).to match_array [tata_salt, lifebuoy, horlicks]
    end

    it "scope published" do
      published_brand
      expect(Brand.published.all).to match_array [published_brand]
    end

    it "scope removed" do
      removed_brand
      expect(Brand.removed.all).to match_array [removed_brand]
    end

    it "scope status" do
      published_brand
      removed_brand
      expect(Brand.status(Brand::UNPUBLISHED)).to match_array [tata_salt, lifebuoy, horlicks]
      expect(Brand.status(Brand::PUBLISHED)).to match_array [published_brand]
      expect(Brand.status(Brand::REMOVED)).to match_array [removed_brand]
    end

    it "scope featured" do
      expect(Brand.featured(false)).to match_array [tata_salt, lifebuoy, horlicks]
      expect(Brand.featured(true)).to match_array [featured_brand]
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
      b = FactoryGirl.create(:unpublished_brand)
      expect(b.status).to match "unpublished"
      b.publish!
      expect(b.status).to match "published"
    end

    it "unpublish!" do
      b = FactoryGirl.create(:published_brand)
      expect(b.status).to match "published"
      b.unpublish!
      expect(b.status).to match "unpublished"
    end

    it "remove!" do
      b = FactoryGirl.create(:published_brand)
      expect(b.status).to match "published"
      b.remove!
      expect(b.status).to match "removed"
    end

    it "can_be_published?, can_be_unpublished? & can_be_removed?" do
      b = FactoryGirl.create(:unpublished_brand)
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
      b = FactoryGirl.create(:unpublished_brand)
      expect(b.can_be_edited?).to be_truthy
    end

    it "can_be_deleted?" do
      skip
    end
  end

end