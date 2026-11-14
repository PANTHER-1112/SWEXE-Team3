require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "有効なユーザー名は保存できること" do
    user = User.new(name: "3班")
    assert user.valid?
  end

  test "空欄のユーザー名は無効であること" do
    user = User.new(name: "   ")
    assert_not user.valid?
  end

  test "重複するユーザー名は無効であること" do
    # fixtures の users(:one) と同じ名前（"1班"）でテストする
    duplicate_user = User.new(name: "1班")
    assert_not duplicate_user.valid?
  end
end
