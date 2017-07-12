# frozen_string_literal: true

class ResponseObserver
  def self.notify(exercise, response)
    ResponseQueue.enqueue(exercise, response) if Rails.env.production?
  end
end
