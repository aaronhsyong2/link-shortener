require "rails_helper"

RSpec.describe Visit, "broadcasts", type: :model do
  include ActiveJob::TestHelper
  include ActionCable::TestHelper

  let(:url) { create(:url) }
  let(:stream_name) { url.to_gid_param }

  describe "after_create_commit" do
    it "broadcasts new visit to URL channel" do
      assert_broadcasts(stream_name, 2) do
        perform_enqueued_jobs do
          create(:visit, url: url, country: nil, city: nil)
        end
      end
    end
  end

  describe "after_update_commit" do
    it "broadcasts when country changes" do
      visit = create(:visit, url: url, country: nil, city: nil)

      assert_broadcasts(stream_name, 1) do
        perform_enqueued_jobs do
          visit.update!(country: "US", city: "New York")
        end
      end
    end

    it "does not broadcast when non-geo fields change" do
      visit = create(:visit, url: url, country: "US", city: "NYC")

      assert_no_broadcasts(stream_name) do
        perform_enqueued_jobs do
          visit.update!(user_agent: "Updated Agent")
        end
      end
    end
  end
end
