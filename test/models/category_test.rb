require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  test "有効なカテゴリは保存できること" do
    category = Category.new(name: "耐震インフラ", disaster_type: "地震")
    assert category.valid?
  end

  test "カテゴリ名または災害タイプが空の場合は無効であること" do
    category = Category.new(name: "", disaster_type: "")
    assert_not category.valid?
    assert_includes category.errors[:name], "can't be blank"
    assert_includes category.errors[:disaster_type], "can't be blank"
  end
end
