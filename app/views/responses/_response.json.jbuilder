# frozen_string_literal: true

json.extract! response, :id, :user_id, :exercise_id, :text, :created_at, :updated_at
json.url response_url(response, format: :json)
