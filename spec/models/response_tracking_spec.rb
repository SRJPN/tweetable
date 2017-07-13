# frozen_string_literal: true

describe ResponsesTracking do
  describe 'validations ' do
    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:exercise_id) }
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:exercise) }
  end

  let(:exercises) do
    [
        {
            title: 'Climate Change', text: 'climate change exercise', commence_time: Time.current, conclude_time: (Time.current + 2.days), duration: '86400'
        },

        {
            title: 'Person', text: 'person exercise', commence_time: Time.current, conclude_time: (Time.current + 2.days), duration: '86400'
        },
        {
            title: 'Program', text: 'program exercise', commence_time: Time.current, conclude_time: (Time.current + 2.days), duration: '86400'
        },
        {
            title: 'Computer', text: 'computer exercise', commence_time: Time.current, conclude_time: (Time.current + 2.days), duration: '0'
        },
        {
            title: 'Human', text: 'human exercise', commence_time: Time.current, conclude_time: (Time.current + 2.days), duration: '86400'
        }
    ]
  end

  let(:users) do
    [
        {
            name: 'Kamal Hasan', admin: false, email: 'kamalhasan@email.com', auth_id: '132271', image_url: 'http://graph.facebook.com/demo1'
        },
        {
            name: 'Vimal Hasan', admin: false, email: 'vimalhasan@email.com', auth_id: '132273', image_url: 'http://graph.facebook.com/demo1'
        },
        {
            name: 'Rajanikanth', admin: false, email: 'rajinikanth@email.com', auth_id: '132272', image_url: 'http://graph.facebook.com/demo2'
        }
    ]
  end

  before(:each) do
    @users = User.create(users)
    @exercises = exercises.map { |exercise|
      task = Task.create(title: exercise[:title], text: exercise[:text])
      exercise_created = task.exercises.create
      ExerciseConfig.create(commence_time: exercise[:commence_time], conclude_time: exercise[:conclude_time], duration: exercise[:duration], exercise_id: exercise_created.id)
      exercise_created
    }
  end

  after(:each) do
    ResponsesTracking.delete_all
    @users.each(&:delete)
    @exercises.each(&:delete)
  end

  describe 'remaining_time' do
    context 'when the candidate has not taken the exercise yet' do
      it 'should save the start time of the ongoing response session for the exercise' do
        remaining_time = ResponsesTracking.remaining_time(@exercises.first.id, @users.first.id)

        expect(remaining_time.round).to eq(86_400)
      end
    end
    context 'when the candidate has started the test and not yet completed' do
      it 'should give remaining time from the time the test started' do
        time = (Time.current - 0.5.day)
        ResponsesTracking.create(exercise_id: @exercises.first.id, user_id: @users.first.id, created_at: time, updated_at: time)
        expected_remaining_time = ResponsesTracking.remaining_time(@exercises.first.id, @users.first.id)

        expect(expected_remaining_time.round).to be(43_200)
      end
      it 'should give remaining time 0 if the duration has ended' do
        time = (Time.current - 1.day)
        ResponsesTracking.create(exercise_id: @exercises.first.id, user_id: @users.first.id, created_at: time, updated_at: time)
        expected_remaining_time = ResponsesTracking.remaining_time(@exercises.first.id, @users.first.id)

        expect(expected_remaining_time.round).to be(0)
      end
      it 'should give remaining time to conclude time if the exercise closing time is less than duration' do
        time = (Time.current + 1.98.day)
        exercise = @exercises.second
        ResponsesTracking.create(exercise_id: exercise.id, user_id: @users.first.id, created_at: time, updated_at: time)
        expected_remaining_time = ResponsesTracking.remaining_time(exercise.id, @users.first.id)

        expect(expected_remaining_time.round).to be(172_800)
      end
      it 'should give remaining time 0 if the response has been submitted' do
        ResponsesTracking.create(exercise_id: @exercises.fifth.id, user_id: @users.first.id, created_at: (Time.current + 1.98))
        ResponsesTracking.update_end_time(@exercises.fifth.id, @users.first.id)
        expected_remaining_time = ResponsesTracking.remaining_time(@exercises.fifth.id, @users.first.id)

        expect(expected_remaining_time.round).to be(0)
      end
    end
    context 'when the duration of the exercise id zero' do
      it 'should give the remaining time as the duration till conculde time' do
        exercise = @exercises.fourth
        user = @users.first
        expected_remaining_time = ResponsesTracking.remaining_time(exercise.id, user.id)
        expect(expected_remaining_time.round).to be(172_800)
      end
      it 'should give remaining time 0 if the response has been submitted' do
        exercise = @exercises.fourth
        ResponsesTracking.create(exercise_id: exercise.id, user_id: @users.first.id, created_at: (Time.current + 1.98))
        ResponsesTracking.update_end_time(exercise.id, @users.first.id)
        expected_remaining_time = ResponsesTracking.remaining_time(exercise.id, @users.first.id)

        expect(expected_remaining_time.round).to be(0)
      end
    end
  end
end
