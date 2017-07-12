# frozen_string_literal: true

describe ExercisesController do
  let(:exercises) do
    [
      {
        title: 'Climate Change', text: 'climate change exercise', commence_time: Time.current, conclude_time: (Time.current + 2), duration: '1'
      }
    ]
  end

  context 'admin specific features' do
    before(:each) do
      stub_logged_in(true)
      stub_current_active_admin_user
    end

    describe 'POST #create' do
      context 'with valid params' do
        it 'redirects to the created exercise' do
          exercise = double('exercise')
          valid_attributes = { title: 'title', duration: 1234 }

          expect(Exercise).to receive(:new).and_return(exercise)
          expect(exercise).to receive(:save).and_return(true)

          post :create, params: { exercise: valid_attributes }

          expect(response).to redirect_to(exercises_path)
          expect(flash[:success]).to match('Exercise was successfully created.')
        end
      end

      context 'with invalid params' do
        it "returns a success response (i.e. to display the 'new' template)" do
          exercise = double('exercise')
          invalid_attributes = { title: 'title', text: 'exercise text', duration: '1234' }

          expect(Exercise).to receive(:new).and_return(exercise)
          expect(exercise).to receive(:save).and_return(false)
          allow_any_instance_of(ExercisesController).to receive(:display_flash_error)

          post :create, params: { exercise: invalid_attributes }

          expect(response).to redirect_to(new_exercise_path)
        end
      end
    end

    describe 'POST #update' do
      context 'with valid params' do
        it 'redirects to the created exercise' do
          exercise = double('exercise')
          valid_attributes = { title: 'title', duration: 1234 }

          expect(Exercise).to receive(:find).and_return(exercise)
          allow_any_instance_of(ExercisesController).to receive(:permit_params).and_return(valid_attributes)
          expect(exercise).to receive(:update_attributes).with(valid_attributes).and_return(true)

          post :update, params: { id: 'id', exercise: valid_attributes }

          expect(response).to redirect_to(exercises_path)
          expect(flash[:success]).to match('Exercise was successfully updated.')
        end
      end

      context 'with invalid params' do
        it "returns a success response (i.e. to display the 'new' template)" do
          exercise = double('exercise')
          valid_attributes = { title: 'title', text: 'exercise text', duration: '1234' }

          expect(Exercise).to receive(:find).and_return(exercise)
          allow_any_instance_of(ExercisesController).to receive(:display_flash_error)
          allow_any_instance_of(ExercisesController).to receive(:permit_params).and_return(valid_attributes)
          expect(exercise).to receive(:update_attributes).with(valid_attributes).and_return(false)

          post :update, params: { id: 'id', exercise: valid_attributes }

          expect(response).to redirect_to(edit_exercise_path)
        end
      end
    end

    describe 'DELETE #destroy' do
      context 'with exercise id' do
        it 'should delete the exercise' do
          @exercises = Exercise.create!(exercises)

          exercise_find_by = Exercise.find_by(title: 'Climate Change')
          delete :destroy, params: { id: exercise_find_by.id }

          expect(Exercise.find_by(title: 'Climate Change')).to eq(nil)
          expect(response).to redirect_to(exercises_path)

          @exercises.each(&:delete)
        end
      end
    end

    describe 'GET #edit' do
      it 'should give edit form for the exercise' do
        exercise = double('Exercise', text: 'This is a exercise text')

        expect(Exercise).to receive(:find).with('12').and_return(exercise)
        get :edit, params: { id: 12 }
        should render_template('exercises/new')
      end
    end

    describe 'PUT #commence' do
      it 'should commence the exercise' do
        past_time = Time.current + 2.days
        exercise = double('Exercise', commence: true)
        expect(Exercise).to receive(:find).and_return(exercise)
        put :commence, params: { id: 12, exercise: { conclude_time: past_time } }
        expect(response).to redirect_to(exercises_path)
      end

      it 'should not commence the exercise' do
        past_time = Time.current - 1.days
        errors = double('Errors', messages: [['conclude_time', 'must be a future time']])
        exercise = double('Exercise', errors: errors)

        expect(exercise).to receive(:commence)
        expect(Exercise).to receive(:find).and_return(exercise)

        put :commence, params: { id: 12, exercise: { conclude_time: past_time } }

        expect(flash[:danger]).to eq('Conclude time must be a future time')
        expect(response).to redirect_to(exercises_path)
      end
    end
  end

  describe 'filter methods' do
    context 'admin filters' do
      before(:each) do
        stub_current_active_admin_user
      end

      describe 'GET #drafts' do
        it 'should give all the yet to open exercises' do
          get :drafts, params: { from_tab: true }
          expect(response).to be_success
          expect(flash[:danger]).to be_nil
          should render_template('exercises/admin/exercises_pane')
        end
      end

      describe 'GET #opened' do
        it 'should give all the yet to open exercises' do
          get :ongoing, params: { from_tab: true }
          expect(response).to be_success
          expect(flash[:danger]).to be_nil
          should render_template('exercises/admin/exercises_pane')
        end
      end

      describe 'GET #concluded' do
        it 'should give all the yet to concluded exercises' do
          get :concluded, params: { from_tab: true }

          expect(response).to be_success
          should render_template('exercises/admin/exercises_pane')
        end
      end
    end

    context 'candidate filters' do
      before(:each) do
        stub_current_active_intern_user
      end

      describe 'GET #commenced' do
        it 'should give all the yet to open exercises' do
          expect(Exercise).to receive(:commence_for_candidate)

          get :commenced

          expect(response).to be_success
          should render_template('exercises/candidate/exercises_pane')
        end
      end

      describe 'GET #missed' do
        it 'should give all the missed exercises by user' do
          expect(Exercise).to receive(:missed_by_candidate)

          get :missed

          expect(response).to be_success
          should render_template('exercises/candidate/exercises_pane')
        end
      end

      describe 'GET #attempted' do
        it 'should give all the exercises that are already attempted by candidate' do
          expect(Exercise).to receive(:attempted_by_candidate)

          get :attempted

          expect(response).to be_success
          should render_template('exercises/candidate/attempted_exercises_pane')
        end
      end
    end
  end

  describe 'validations' do
    before(:each) do
      stub_current_active_intern_user
    end

    it 'should not allow candidate to create a exercise' do
      expect { post :create }.to raise_error(ActionController::RoutingError)
    end

    it 'should not allow candidate to edit a exercise' do
      expect { post :update, params: { id: 'some_id' } }.to raise_error(ActionController::RoutingError)
    end

    it 'should not allow candidate to commence a exercise' do
      expect { post :commence, params: { id: 'some_id' } }.to raise_error(ActionController::RoutingError)
    end

    it 'should not allow candidate to conclude a exercise' do
      expect { post :conclude, params: { id: 'some_id' } }.to raise_error(ActionController::RoutingError)
    end

    it 'should not have access to concluded exercises' do
      expect { get :concluded }.to raise_error(ActionController::RoutingError)
    end

    it 'should not have access to opened exercises' do
      expect { get :ongoing }.to raise_error(ActionController::RoutingError)
    end

    it 'should not have access to drafts exercises' do
      expect { get :drafts }.to raise_error(ActionController::RoutingError)
    end
  end
end
