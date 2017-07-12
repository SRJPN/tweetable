# frozen_string_literal: true

require 'rails_helper'

describe ResponsesController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/exercises/1/responses').to route_to('responses#index', exercise_id: '1')
    end
  end
end
