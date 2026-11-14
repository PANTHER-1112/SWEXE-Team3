require "test_helper"

class StampLogTest < ActiveSupport::TestCase
  test "未訪問の施設にはスタンプを記録できること" do
    # users(:one) は fixtures 上で facilities(:one) のみ訪問済みのため、facilities(:two) は登録可能
    stamp_log = StampLog.new(
      user: users(:one),
      facility: facilities(:two),
      visited_at: Time.current
    )
    assert stamp_log.valid?
  end

  test "同じユーザーが同じ施設へ重複してスタンプを押せないこと" do
    duplicate_log = StampLog.new(
      user: users(:one),
      facility: facilities(:one),
      visited_at: Time.current
    )
    assert_not duplicate_log.valid?
  end
end
