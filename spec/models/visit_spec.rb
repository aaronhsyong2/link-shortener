require "rails_helper"

RSpec.describe Visit, type: :model do
  describe "associations" do
    it "belongs to a url" do
      visit = create(:visit)
      expect(visit.url).to be_a(Url)
    end

    it "requires a url" do
      visit = build(:visit, url: nil)
      expect(visit).not_to be_valid
    end
  end
end
