require "test_helper"

class FacilityTest < ActiveSupport::TestCase
  test "有効な施設データは保存できること" do
    facility = Facility.new(
      category: categories(:one),
      name: "市民体育館",
      description: "広い体育館で多くの人が避難できます。",
      address: "山口県美祢市3-3",
      map_x: 0.0,
      map_y: 100.0
    )
    assert facility.valid?
  end

  test "座標が0.0〜100.0の範囲外の場合は無効であること" do
    facility = facilities(:one).dup
    facility.map_x = -0.1
    assert_not facility.valid?

    facility.map_x = 50.0
    facility.map_y = 100.1
    assert_not facility.valid?
  end
end
