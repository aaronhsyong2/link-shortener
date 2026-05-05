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

  describe "#slug" do
    it "returns a deterministic slug from id" do
      url = create(:url)
      expect(url.slug).to eq(url.slug)
      expect(url.slug).to be_present
    end

    it "produces slugs with minimum length of 4" do
      url = create(:url)
      expect(url.slug.length).to be >= 4
    end

    it "produces alphanumeric slugs" do
      url = create(:url)
      expect(url.slug).to match(/\A[a-zA-Z0-9]+\z/)
    end

    it "is decodable back to the id" do
      url = create(:url)
      decoded = Url::SQIDS.decode(url.slug)
      expect(decoded).to eq([url.id])
    end

    it "produces different slugs for different ids" do
      url1 = create(:url)
      url2 = create(:url)
      expect(url1.slug).not_to eq(url2.slug)
    end

    it "raises on unsaved record" do
      url = build(:url)
      expect { url.slug }.to raise_error(RuntimeError, /unsaved record/)
    end
  end

  describe ".from_slug" do
    it "finds a url by its slug" do
      url = create(:url)
      expect(Url.from_slug(url.slug)).to eq(url)
    end

    it "raises RecordNotFound for invalid slugs" do
      expect { Url.from_slug("!!!") }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "raises RecordNotFound for nil slug" do
      expect { Url.from_slug(nil) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "raises RecordNotFound for blank slug" do
      expect { Url.from_slug("") }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "raises RecordNotFound for non-existent ids" do
      slug = Url::SQIDS.encode([999999])
      expect { Url.from_slug(slug) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
