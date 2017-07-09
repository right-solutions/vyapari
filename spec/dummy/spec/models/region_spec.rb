require 'spec_helper'

RSpec.describe Region, type: :model do

  let(:ind) {FactoryGirl.create(:country, name: "India", code: "IND")}
  let(:usa) {FactoryGirl.create(:country, name: "United States of America", code: "USA")}
  let(:uae) {FactoryGirl.create(:country, name: "United Arab Emirates", code: "UAE")}

  let(:dub) {FactoryGirl.create(:region, name: "Dubai", code: "DXB", country: uae)}
  let(:ker) {FactoryGirl.create(:region, name: "Kerala", code: "KER", country: ind)}
  let(:cal) {FactoryGirl.create(:region, name: "California", code: "CAL", country: usa)}
  
  context "Factory" do
    it "should validate all the factories" do
      expect(FactoryGirl.build(:region).valid?).to be true
    end
  end

  context "Validations" do
    it { should validate_presence_of :name }
    it { should allow_value('Greater Noida Region').for(:name )}
    it { should allow_value('RAK').for(:name )}
    it { should allow_value('US').for(:name )}
    it { should_not allow_value("X").for(:name )}
    it { should_not allow_value("x"*251).for(:name )}

    it { should validate_presence_of :code }
    it { should allow_value('GCOK').for(:code )}
    it { should allow_value('US').for(:code )}
    it { should_not allow_value("X").for(:code )}
    it { should_not allow_value("x"*17).for(:code )}
  end

  context "Associations" do
    it { should belong_to(:country) }
    it { should have_many(:stores) }
  end

  context "Class Methods" do
    it "search" do
      [dub, ker, cal]

      # Region Name Search
      expect(Region.search("Dubai")).to match_array([dub])      
      expect(Region.search("Kerala")).to match_array([ker])      
      expect(Region.search("California")).to match_array([cal])      

      # Country Name Search
      expect(Region.search("United States")).to match_array([cal])
      expect(Region.search("India")).to match_array([ker])
      expect(Region.search("United")).to match_array([cal, dub])
    end

    context "Import Methods" do

      it "save_row_data" do
        skip
      end

    end
    
  end

  context "Instance Methods" do

    it "display_name" do
      cal.name = "Changed"
      expect(cal.display_name).to match("California")
    end

    it "can_be_edited?" do
      skip
    end

    it "can_be_deleted?" do
      skip
    end

  end

end