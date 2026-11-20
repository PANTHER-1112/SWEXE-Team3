require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "新しいニックネームでログインするとユーザーが増えトップへリダイレクトされること" do
    assert_difference("User.count", 1) do
      post session_url, params: { name: "新しい3班" }
    end

    assert_redirected_to root_url
    follow_redirect!
    assert_match "新しい3班", response.body
  end

  test "既存のニックネームでログインすると重複作成されず既存ユーザーでログインできること" do
    assert_no_difference("User.count") do
      post session_url, params: { name: users(:one).name }
    end

    assert_redirected_to root_url
  end

  test "空欄で送信しても500エラーにならずトップ画面へ戻されること" do
    assert_no_difference("User.count") do
      post session_url, params: { name: "   " }
    end

    assert_redirected_to root_url
    assert_not_nil flash[:alert]
  end

  test "ログアウトできること" do
    post session_url, params: { name: "1班" }
    delete session_url

    assert_redirected_to root_url
  end
end
