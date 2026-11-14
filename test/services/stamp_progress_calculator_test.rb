# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../app/services/stamp_progress_calculator"

class StampProgressCalculatorTest < Minitest::Test
  def test_no_stamp_has_been_collected
    result = calculate(
      facility_ids: [1, 2, 3],
      stamped_facility_ids: []
    )

    assert_equal 3, result[:total_count]
    assert_equal 0, result[:stamped_count]
    assert_equal 3, result[:remaining_count]
    assert_equal 0, result[:completion_rate]
    refute result[:completed]
  end

  def test_some_stamps_have_been_collected
    result = calculate(
      facility_ids: [1, 2, 3],
      stamped_facility_ids: [1]
    )

    assert_equal 3, result[:total_count]
    assert_equal 1, result[:stamped_count]
    assert_equal 2, result[:remaining_count]
    assert_equal 33, result[:completion_rate]
    refute result[:completed]
  end

  def test_all_stamps_have_been_collected
    result = calculate(
      facility_ids: [1, 2, 3],
      stamped_facility_ids: [1, 2, 3]
    )

    assert_equal 3, result[:total_count]
    assert_equal 3, result[:stamped_count]
    assert_equal 0, result[:remaining_count]
    assert_equal 100, result[:completion_rate]
    assert result[:completed]
  end

  def test_duplicate_stamps_are_counted_only_once
    result = calculate(
      facility_ids: [1, 2, 3],
      stamped_facility_ids: [1, 1, 1]
    )

    assert_equal 1, result[:stamped_count]
    assert_equal 2, result[:remaining_count]
  end

  def test_unknown_facility_ids_are_ignored
    result = calculate(
      facility_ids: [1, 2, 3],
      stamped_facility_ids: [1, 4, 5]
    )

    assert_equal 1, result[:stamped_count]
    assert_equal 2, result[:remaining_count]
  end

  def test_zero_facilities_are_not_completed
    result = calculate(
      facility_ids: [],
      stamped_facility_ids: []
    )

    assert_equal 0, result[:total_count]
    assert_equal 0, result[:stamped_count]
    assert_equal 0, result[:remaining_count]
    assert_equal 0, result[:completion_rate]
    refute result[:completed]
  end

  def test_nil_is_treated_as_an_empty_array
    result = calculate(
      facility_ids: nil,
      stamped_facility_ids: nil
    )

    assert_equal 0, result[:total_count]
    assert_equal 0, result[:stamped_count]
    assert_equal 0, result[:completion_rate]
    refute result[:completed]
  end

  def test_input_arrays_are_not_modified
    facility_ids = [1, 1, 2, nil]
    stamped_facility_ids = [1, 1, 3]

    original_facility_ids = facility_ids.dup
    original_stamped_facility_ids =
      stamped_facility_ids.dup

    calculate(
      facility_ids: facility_ids,
      stamped_facility_ids: stamped_facility_ids
    )

    assert_equal original_facility_ids, facility_ids
    assert_equal(
      original_stamped_facility_ids,
      stamped_facility_ids
    )
  end

  private

  def calculate(facility_ids:, stamped_facility_ids:)
    StampProgressCalculator.call(
      facility_ids: facility_ids,
      stamped_facility_ids: stamped_facility_ids
    )
  end
end