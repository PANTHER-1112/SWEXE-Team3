require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  test "許可された災害タイプのカテゴリはすべて保存できること" do
    assert Category.new(name: "耐震インフラ", disaster_type: "震災").valid?
    assert Category.new(name: "排水ポンプ場", disaster_type: "風水害").valid?
    assert Category.new(name: "砂防ダム", disaster_type: "土砂").valid?
  end

  test "許可されていない災害タイプは無効であること" do
    earthquake = Category.new(name: "旧分類施設1", disaster_type: "地震")
    flood = Category.new(name: "旧分類施設2", disaster_type: "水害")
    assert_not earthquake.valid?
    assert_includes earthquake.errors[:disaster_type], "is not included in the list"
    assert_not flood.valid?
    assert_includes flood.errors[:disaster_type], "is not included in the list"
  end

  test "カテゴリ名または災害タイプが空・nilの場合は無効であること" do
    blank_category = Category.new(name: "", disaster_type: "")
    assert_not blank_category.valid?
    assert_includes blank_category.errors[:name], "can't be blank"
    assert_includes blank_category.errors[:disaster_type], "can't be blank"

    nil_category = Category.new(name: "避難所", disaster_type: nil)
    assert_not nil_category.valid?
    assert_includes nil_category.errors[:disaster_type], "can't be blank"
  end
end
