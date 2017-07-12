# frozen_string_literal: true

RSpec.describe 'Exercises', type: :request do
  describe 'GET /exercises' do
    it 'works! (now write some real specs)' do
      get exercises_path
      expect(response).to have_http_status(302)
    end
  end
end
