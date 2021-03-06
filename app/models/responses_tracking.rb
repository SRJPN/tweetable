# frozen_string_literal: true

class ResponsesTracking < ApplicationRecord
  validates :user_id, presence: true
  validates :exercise_id, presence: true

  belongs_to :exercise
  belongs_to :user

  def self.remaining_time(exercise_id, user_id)
    tracking_detail = ResponsesTracking.find_or_create_by(exercise_id: exercise_id, user_id: user_id)
    return 0 unless tracking_detail.updated_at.eql? tracking_detail.created_at

    current_time = Time.current
    conclude_time_duration = tracking_detail.exercise.conclude_time - current_time
    exercise_duration = tracking_detail.exercise.duration
    return conclude_time_duration if exercise_duration.zero? || exercise_duration.nil?

    remaining_time = exercise_duration - (current_time - tracking_detail.created_at)
    [remaining_time, conclude_time_duration].min
  end

  def self.update_end_time(exercise_id, user_id)
    tracking_detail = ResponsesTracking.find_by(exercise_id: exercise_id, user_id: user_id)
    tracking_detail.touch(:updated_at)
  end
end
