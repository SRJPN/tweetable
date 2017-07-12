# frozen_string_literal: true

describe ExercisesController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/exercises').to route_to('exercises#index')
    end

    it 'routes to #new' do
      expect(get: '/exercises/new').to route_to('exercises#new')
    end

    it 'routes to #show' do
      expect(get: '/exercises/1').to route_to('exercises#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/exercises/1/edit').to route_to('exercises#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/exercises').to route_to('exercises#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/exercises/1').to route_to('exercises#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/exercises/1').to route_to('exercises#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/exercises/1').to route_to('exercises#destroy', id: '1')
    end

    it 'routes to #commence' do
      expect(put: '/exercises/1/commence').to route_to('exercises#commence', id: '1')
    end

    it 'routes to #conclude' do
      expect(get: '/exercises/1/conclude').to route_to('exercises#conclude', id: '1')
    end

    it 'routes to #passasges/drafts' do
      expect(get: '/exercises/drafts').to route_to('exercises#drafts')
    end

    it 'routes to #passasges/ongoing' do
      expect(get: '/exercises/ongoing/').to route_to('exercises#ongoing')
    end

    it 'routes to #passasges/ongoing with params' do
      expect(get: '/exercises/ongoing?query=something').to route_to('exercises#ongoing', query: 'something')
    end

    it 'routes to #passasges/concluded' do
      expect(get: '/exercises/concluded/').to route_to('exercises#concluded')
    end

    it 'routes to #passasges/concluded with params' do
      expect(get: '/exercises/concluded?query=something').to route_to('exercises#concluded', query: 'something')
    end
  end
end
