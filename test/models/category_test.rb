require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  test "許可された災害タイプのカテゴリはすべて保存できること" do
    assert Category.new(name: "耐震インフラ", disaster_type: "震災").valid?
    assert Category.new(name: "排水ポンプ場", disaster_type: "風水害").valid?
    assert Category.new(name: "砂防ダム", disaster_type: "土砂").valid?
  end

  test "許可されていない災害タイプは無効であること" do
    category = Category.new(name: "旧分類施設", disaster_type: "地震")
    assert_not category.valid?
    assert_includes category.errors[:disaster_type], "is not included in the list"
  end

  test "カテゴリ名または災害タイプが空の場合は無効であること" do
    category = Category.new(name: "", disaster_type: "")
    assert_not category.valid?
    assert_includes category.errors[:name], "can't be blank"
    assert_includes category.errors[:disaster_type], "can't be blank"
  end
end
