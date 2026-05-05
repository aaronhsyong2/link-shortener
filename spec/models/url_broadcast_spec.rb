require "rails_helper"

RSpec.describe Url, "title broadcast", type: :model do
  include ActiveJob::TestHelper
  include ActionCable::TestHelper

  describe "after_update_commit" do
    it "broadcasts when title changes from nil to a value" do
      url = create(:url, title: nil)

      assert_broadcasts("url_titles", 1) do
        perform_enqueued_jobs do
          url.update!(title: "New Title")
        end
      end
    end

    it "does not broadcast when title is unchanged" do
      url = create(:url, title: "Existing")

      assert_no_broadcasts("url_titles") do
        perform_enqueued_jobs do
          url.update!(clicks_count: 5)
        end
      end
    end

    it "does not broadcast when title is set to nil" do
      url = create(:url, title: "Existing")

      assert_no_broadcasts("url_titles") do
        perform_enqueued_jobs do
          url.update!(title: nil)
        end
      end
    end
  end
end
