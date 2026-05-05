require "rails_helper"

RSpec.describe ChartsHelper, type: :helper do
  describe "#chart_library_options" do
    it "returns scales with grid and tick colors" do
      opts = helper.chart_library_options
      expect(opts[:scales][:x][:grid][:color]).to be_present
      expect(opts[:scales][:x][:ticks][:color]).to be_present
      expect(opts[:scales][:y][:beginAtZero]).to be true
    end

    it "includes legend label color" do
      opts = helper.chart_library_options
      expect(opts[:plugins][:legend][:labels][:color]).to be_present
    end
  end

  describe "#pie_chart_library_options" do
    it "returns legend label color without scales" do
      opts = helper.pie_chart_library_options
      expect(opts[:plugins][:legend][:labels][:color]).to be_present
      expect(opts).not_to have_key(:scales)
    end
  end
end
