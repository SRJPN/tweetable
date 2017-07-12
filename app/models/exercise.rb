# frozen_string_literal: true

class Exercise < ApplicationRecord
  after_initialize :defaults, unless: :persisted?

  validates_numericality_of :duration, greater_than_or_equal_to: 0
  validate :date_validations
  validates :task_id, presence: true

  belongs_to :task
  has_many :responses, dependent: :destroy
  has_many :responses_trackings, dependent: :destroy

  DEFAULT_DURATION = 3600

  def title
    task.title
  end

  def text
    task.text
  end

  def commence(conclude_time)
    update_attributes(commence_time: Time.current, conclude_time: conclude_time)
  end

  def conclude
    update_attributes(conclude_time: Time.current)
  end

  def self.drafts
    Exercise.where(['commence_time > ?', Time.current]).or(Exercise.where(commence_time: nil))
  end

  def self.ongoing
    now = Time.current
    Exercise.where(['commence_time <= ? and conclude_time > ?', now, now])
  end

  def self.concluded
    Exercise.where(['conclude_time < ?', Time.current])
  end

  def self.commence_for_candidate(user)
    ongoing_exercises = ongoing
    (ongoing_exercises - user.exercises) - get_timed_out_exercises(ongoing_exercises, user.id)
  end

  def self.missed_by_candidate(user)
    timed_out_exercises = get_timed_out_exercises(ongoing, user.id)
    (concluded + timed_out_exercises) - user.exercises
  end

  def self.attempted_by_candidate(user)
    exercises = user.exercises
    responses = user.responses
    exercises.map { |exercise| { exercise: exercise, response: get_exercises_with_corresponding_response(responses, exercise.id) } }
  end

  def self.get_exercises_with_corresponding_response(responses, exercise_id)
    responses.find { |response| response.exercise_id.equal?(exercise_id) }
  end

  def self.exercise_missed?(exercise, user_id)
    tracking_details = ResponsesTracking.find_by(exercise_id: exercise.id, user_id: user_id)
    return false if tracking_details.nil?
    ResponsesTracking.remaining_time(exercise.id, user_id) <= 0
  end

  def self.get_timed_out_exercises(ongoing_exercises, user_id)
    ongoing_exercises.select { |exercise| exercise_missed?(exercise, user_id) }
  end

  private_class_method :exercise_missed?, :get_exercises_with_corresponding_response, :get_timed_out_exercises

  private

  def date_validations
    return if valid_commence_time?
    errors.add(:conclude_time, 'must be a future time...')
  end

  def valid_conclude_time?
    conclude_time.present? && conclude_time > commence_time
  end

  def valid_commence_time?
    return true unless commence_time.present?
    valid_conclude_time?
  end

  def defaults
    self.duration ||= DEFAULT_DURATION
  end
end