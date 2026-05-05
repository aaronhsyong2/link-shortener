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

    describe "embedded credentials" do
      it "rejects URLs with user:pass" do
        url = build(:url, target_url: "http://user:pass@example.com/path")
        expect(url).not_to be_valid
        expect(url.errors[:target_url]).to include("must not contain embedded credentials")
      end

      it "allows URLs without credentials" do
        url = build(:url, target_url: "https://example.com/path")
        expect(url).to be_valid
      end
    end

    describe "private IP rejection" do
      %w[
        http://127.0.0.1/admin
        http://10.0.0.1/internal
        http://172.16.0.1/secret
        http://192.168.1.1/router
        http://[::1]/ipv6
      ].each do |private_url|
        it "rejects #{private_url}" do
          url = build(:url, target_url: private_url)
          expect(url).not_to be_valid
          expect(url.errors[:target_url]).to include("must not point to a private or localhost address")
        end
      end

      it "allows public IPs" do
        url = build(:url, target_url: "http://8.8.8.8/dns")
        expect(url).to be_valid
      end

      it "allows domain names (no DNS resolution)" do
        url = build(:url, target_url: "https://example.com")
        expect(url).to be_valid
      end
    end

    describe "self-referential rejection" do
      before do
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch).with("SHORTENER_HOSTS", "").and_return("short.ly,localhost")
      end

      it "rejects URLs pointing to shortener host" do
        url = build(:url, target_url: "http://short.ly/abc")
        expect(url).not_to be_valid
        expect(url.errors[:target_url]).to include("must not point back to this shortener")
      end

      it "rejects case-insensitively" do
        url = build(:url, target_url: "http://SHORT.LY/abc")
        expect(url).not_to be_valid
      end

      it "handles comma-separated hosts" do
        url = build(:url, target_url: "http://localhost/abc")
        expect(url).not_to be_valid
      end

      it "allows non-shortener hosts" do
        url = build(:url, target_url: "https://example.com")
        expect(url).to be_valid
      end

      it "skips check when SHORTENER_HOSTS is empty" do
        allow(ENV).to receive(:fetch).with("SHORTENER_HOSTS", "").and_return("")
        url = build(:url, target_url: "http://short.ly/abc")
        expect(url).to be_valid
      end
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
      expect(decoded).to eq([ url.id ])
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
      slug = Url::SQIDS.encode([ 999999 ])
      expect { Url.from_slug(slug) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
