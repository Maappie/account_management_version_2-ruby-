require "test_helper"

class CreateAccountControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get create_account_new_url
    assert_response :success
  end

  test "should get create" do
    get create_account_create_url
    assert_response :success
  end
end
