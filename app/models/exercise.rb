# frozen_string_literal: true

class Exercise < ApplicationRecord
  scope :drafts, -> { ExerciseConfig.where(['commence_time > ?', Time.current]).or(ExerciseConfig.where(commence_time: nil)).map(&:exercise) }
  scope :ongoing, -> { now = Time.current; ExerciseConfig.where(['commence_time <= ? and conclude_time > ?', now, now]).map(&:exercise) }
  scope :concluded, -> { ExerciseConfig.where(['conclude_time < ?', Time.current]).map(&:exercise) }

  validates :task_id, presence: true

  belongs_to :task
  accepts_nested_attributes_for :task

  has_one :exercise_config
  accepts_nested_attributes_for :exercise_config

  has_many :responses, dependent: :destroy
  has_many :responses_trackings, dependent: :destroy

  def title
    task.title
  end

  def text
    task.text
  end

  def commence_time
    exercise_config.commence_time
  end

  def duration
    exercise_config.duration
  end

  def conclude_time
    exercise_config.conclude_time
  end

  def commence(conclude_time)
    exercise_config.update_attributes(commence_time: Time.current, conclude_time: conclude_time)
  end

  def conclude
    exercise_config.update_attributes(conclude_time: Time.current)
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
end
