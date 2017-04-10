require 'spec_helper'

RSpec.describe Country, type: :model do

  let(:ind) {FactoryGirl.create(:country, name: "India", code: "IND")}
  let(:usa) {FactoryGirl.create(:country, name: "United States of America", code: "USA")}
  let(:uae) {FactoryGirl.create(:country, name: "United Arab Emirates", code: "UAE")}
  
  context "Factory" do
    it "should validate all the factories" do
      expect(FactoryGirl.build(:country).valid?).to be true
    end
  end

  context "Validations" do
    it { should validate_presence_of :name }
    it { should allow_value('United States of America').for(:name )}
    it { should allow_value('USA').for(:name )}
    it { should allow_value('US').for(:name )}
    it { should_not allow_value("X").for(:name )}
    it { should_not allow_value("x"*129).for(:name )}

    it { should validate_presence_of :code }
    it { should allow_value('USA').for(:code )}
    it { should allow_value('US').for(:code )}
    it { should_not allow_value("X").for(:code )}
    it { should_not allow_value("x"*17).for(:code )}
  end

  context "Associations" do
    it { should have_many(:regions) }
    it { should have_many(:stores) }
  end

  context "Class Methods" do
    it "search" do
      [ind, usa, uae]
      expect(Country.search("United States")).to match_array([usa])
      expect(Country.search("India")).to match_array([ind])
      expect(Country.search("United")).to match_array([usa, uae])
    end

    context "Import Methods" do

      it "save_row_data" do
        skip
      end

    end
    
  end

  context "Instance Methods" do

    it "display_name" do
      usa.name = "Changed"
      expect(usa.display_name).to match("United States of America")
    end

    it "can_be_edited?" do
      skip
    end

    it "can_be_deleted?" do
      skip
    end

  end

end