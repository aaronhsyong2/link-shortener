require "rails_helper"

RSpec.describe Url, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      url = build(:url)
      expect(url).to be_valid
    end

    it "requires target_url" do
      url = build(:url, target_url: nil)
      expect(url).not_to be_valid
      expect(url.errors[:target_url]).to include("can't be blank")
    end

    it "requires a valid HTTP or HTTPS URL" do
      url = build(:url, target_url: "not-a-url")
      expect(url).not_to be_valid
      expect(url.errors[:target_url]).to include("must be a valid HTTP or HTTPS URL")
    end

    it "rejects javascript: URLs" do
      url = build(:url, target_url: "javascript:alert('xss')")
      expect(url).not_to be_valid
    end

    it "requires short_code" do
      url = build(:url, short_code: nil)
      expect(url).not_to be_valid
    end

    it "enforces short_code uniqueness" do
      existing = create(:url)
      duplicate = build(:url, short_code: existing.short_code)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:short_code]).to include("has already been taken")
    end

    it "enforces short_code max length of 15" do
      url = build(:url, short_code: "a" * 16)
      expect(url).not_to be_valid
    end

    it "accepts short_code at max length of 15" do
      url = build(:url, short_code: "a" * 15)
      expect(url).to be_valid
    end
  end

  describe "associations" do
    it "has many visits" do
      url = create(:url)
      create(:visit, url: url)
      create(:visit, url: url)
      expect(url.visits.count).to eq(2)
    end

    it "destroys associated visits when destroyed" do
      url = create(:url)
      create(:visit, url: url)
      expect { url.destroy }.to change(Visit, :count).by(-1)
    end
  end
end
