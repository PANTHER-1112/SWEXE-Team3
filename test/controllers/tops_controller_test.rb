require "test_helper"

class TopsControllerTest < ActionDispatch::IntegrationTest
  test "未ログイン状態でトップ画面が表示でき、参加フォームが出ること" do
    get root_url
    assert_response :success
    assert_match "参加する", response.body
  end

  test "ログイン後はトップ画面にユーザー名とログアウトボタンが表示されること" do
    post session_url, params: { name: "1班" }

    get root_url
    assert_response :success
    assert_match "1班", response.body
  end
end
