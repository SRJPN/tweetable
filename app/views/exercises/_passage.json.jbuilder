# frozen_string_literal: true

json.extract! exercise, :id, :created_at, :updated_at
json.url passage_url(exercise, format: :json)
