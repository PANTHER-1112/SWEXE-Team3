# frozen_string_literal: true

class StampProgressCalculator
  def self.call(facility_ids:, stamped_facility_ids:)
    new(
      facility_ids: facility_ids,
      stamped_facility_ids: stamped_facility_ids
    ).call
  end

  def initialize(facility_ids:, stamped_facility_ids:)
    @facility_ids = normalize(facility_ids)
    @stamped_facility_ids = normalize(stamped_facility_ids)
  end

  def call
    valid_stamped_facility_ids =
      @facility_ids & @stamped_facility_ids

    total_count = @facility_ids.length
    stamped_count = valid_stamped_facility_ids.length
    remaining_count = total_count - stamped_count

    {
      total_count: total_count,
      stamped_count: stamped_count,
      remaining_count: remaining_count,
      completion_rate: completion_rate(
        stamped_count,
        total_count
      ),
      completed: completed?(stamped_count, total_count)
    }
  end

  private

  def normalize(ids)
    Array(ids).compact.uniq
  end

  def completion_rate(stamped_count, total_count)
    return 0 if total_count.zero?

    ((stamped_count.to_f / total_count) * 100).round
  end

  def completed?(stamped_count, total_count)
    total_count.positive? && stamped_count == total_count
  end
end