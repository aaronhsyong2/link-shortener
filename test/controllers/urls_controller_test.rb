require "test_helper"

class UrlsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @url = urls(:one)
  end

  test "should get index" do
    get urls_url
    assert_response :success
  end

  test "should get new" do
    get new_url_url
    assert_response :success
  end

  test "should create url" do
    assert_difference("Url.count") do
      post urls_url, params: { url: { target_url: "https://example.org" } }
    end

    assert_redirected_to url_url(Url.last)
  end

  test "should show url" do
    get url_url(@url)
    assert_response :success
  end
end
