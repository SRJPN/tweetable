# frozen_string_literal: true

module ExercisesHelper
  DRAFT_PASSAGES = 'drafts_exercises'.freeze

  def admin_tabs
    { drafts: :drafts, ongoing: :ongoing, concluded: :concluded, new: :new }
  end

  def candidate_tabs
    { commenced: :commenced, attempted: :attempted, missed: :missed }
  end

  def self.partial_name(tab_name)
    partial_list = {
      drafts: 'drafts_exercises',
      ongoing: 'ongoing_exercises',
      concluded: 'concluded_exercises',
      commenced: 'commenced_exercises',
      attempted: 'attempted_exercises',
      missed: 'missed_exercises'
    }
    partial_list[tab_name]
  end

  def self.empty_tab_messages(partial_name)
    empty_tab_messages = {
      partial_name(:drafts) => 'No drafts yet, Create One',
      partial_name(:ongoing) => 'No ongoing exercises, Commence One',
      partial_name(:concluded) => 'No exercises are Concluded yet!',
      partial_name(:commenced) => 'No exercises are commenced. Chill !',
      partial_name(:attempted) => 'You have not yet attempted any exercises.',
      partial_name(:missed) => 'Hurray! You haven\'t missed any exercises yet.'
    }
    empty_tab_messages[partial_name]
  end

  def to_preferred_time_format(time)
    time.strftime('%d-%m-%Y %I:%M%p') unless time.nil?
  end

  def drafts_exercise_partial?(partial)
    partial.eql?(DRAFT_PASSAGES)
  end

  def to_display_time_format(time)
    time.strftime('%d %b %I:%m %p')
  end

  def duration_of_interval_in_words(interval)
    interval_time = Time.at(interval).utc.strftime('%H:%M')
    hours, minutes = interval_time.split(':').map(&:to_i)

    [].tap do |parts|
      parts << "#{hours} hour".pluralize(hours) unless hours.zero?
      parts << "#{minutes} minute".pluralize(minutes) unless minutes.zero?
    end.join(', ')
  end

  def evaluation_count(exercise_responses)
    exercise_responses.map do |response|
      tags = response.tags
      !(tags.nil? || tags.empty?)
    end.count(true)
  end
end
