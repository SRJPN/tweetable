# frozen_string_literal: true

describe Exercise, type: :model do
  describe 'validations ' do
    it { should validate_presence_of(:task) }
  end

  describe 'associations' do
    it { should have_many(:responses).dependent(:destroy) }

    it { should belong_to(:task) }
  end

  describe 'commence' do
    it 'should set the conclude time as current time' do
      Time.zone = 'Astana'
      task = Task.create(title: 'exercise title', text: 'exercise text')
      exercise = Exercise.create(task_id: task.id)
      ExerciseConfig.create(duration: 86_400, exercise_id: exercise.id)
      now = Time.now.in_time_zone(ActiveSupport::TimeZone.new('Chennai'))
      exercise.commence(now.to_s)
      expect(exercise.conclude_time).to eq(Time.zone.parse(now.to_s))
    end
  end

  describe 'open_exercises' do
    it 'should get all open exercises' do
      now = Time.current
      expect(Time).to receive(:current).and_return(now)
      expect(ExerciseConfig).to receive(:where).with(['commence_time <= ? and conclude_time > ?', now, now]).and_return([])
      Exercise.ongoing
    end
  end

  describe 'draft_exercises' do
    it 'should get all draft exercises' do
      now = Time.current
      expect(Time).to receive(:current).and_return(now)
      exercise_or = double('OR')
      exercises = double('exercises')
      expect(ExerciseConfig).to receive(:where).with(commence_time: nil)
      expect(exercise_or).to receive(:or).and_return exercises
      expect(ExerciseConfig).to receive(:where).with(['commence_time > ?', now]).and_return(exercise_or)
      expect(exercises).to receive(:map)
      Exercise.drafts
    end
  end

  describe '#concluded_exercises' do
    it 'should get all concluded exercises' do
      now = Time.current
      exercises = double('exercises')
      expect(Time).to receive(:current).and_return(now)
      expect(ExerciseConfig).to receive(:where).with(['conclude_time < ?', now]).and_return exercises
      expect(exercises).to receive(:map)
      Exercise.concluded
    end
  end

  describe 'commence_for_candidate_exercises' do
    it 'should get all open exercises for the candidate which are not attempted by user' do
      exercise1 = double('Exercise 1', id: 11)
      exercise2 = double('Exercise 2', id: 12)
      user = double('User', id: 1)

      expect(Exercise).to receive(:ongoing).and_return([exercise1, exercise2])
      expect(user).to receive(:exercises).and_return([exercise1])
      exercise_open_for_candidate = Exercise.commence_for_candidate(user)

      expect(exercise_open_for_candidate.count).to be(1)
      expect(exercise_open_for_candidate).to contain_exactly(exercise2)
    end
    it 'should not get exercises that are open but remaining time is expired' do
      exercise1 = double('Exercise 1', id: 11)
      exercise2 = double('Exercise 2', id: 12)
      user = double('User', id: 1)
      tracking_details2 = double('Responses Tracking')

      expect(Exercise).to receive(:ongoing).and_return([exercise1, exercise2])
      expect(user).to receive(:exercises).and_return([])
      expect(ResponsesTracking).to receive(:find_by).with(exercise_id: exercise1.id, user_id: user.id).and_return(nil)
      expect(ResponsesTracking).to receive(:find_by).with(exercise_id: exercise2.id, user_id: user.id).and_return(tracking_details2)
      expect(ResponsesTracking).to receive(:remaining_time).and_return(0)

      exercise_open_for_candidate = Exercise.commence_for_candidate(user)

      expect(exercise_open_for_candidate.count).to be(1)
      expect(exercise_open_for_candidate).to contain_exactly(exercise1)
    end
  end

  describe '#missed_by_candidate_exercises' do
    it 'should get all missed exercises for the candidate which are not attempted by user' do
      exercise1 = double('Exercise 1', id: 11, duration: 4600)
      exercise2 = double('Exercise 2', id: 12)
      user = double('User', id: 1)

      expect(Exercise).to receive(:concluded).and_return([exercise1, exercise2])
      expect(user).to receive(:exercises).and_return([exercise1])
      exercise_missed_for_candidate = Exercise.missed_by_candidate(user)

      expect(exercise_missed_for_candidate.count).to be(1)
      expect(exercise_missed_for_candidate).to contain_exactly(exercise2)
    end
    it 'should get all missed exercises for the candidate which are not attempted by user in the remaining time' do
      concluded_psg1 = double('Exercise 1', id: 11, duration: 4600)
      concluded_psg2 = double('Exercise 2', id: 12)
      ongoing_psg1 = double('Exercise 3', id: 13)
      ongoing_psg2 = double('Exercise 4', id: 14)
      tracking_details2 = double('Responses Tracking')

      user = double('User', id: 1)

      expect(Exercise).to receive(:concluded).and_return([concluded_psg1, concluded_psg2])
      expect(user).to receive(:exercises).and_return([concluded_psg2])
      expect(Exercise).to receive(:ongoing).and_return([ongoing_psg1, ongoing_psg2])
      expect(ResponsesTracking).to receive(:find_by).with(exercise_id: ongoing_psg1.id, user_id: user.id).and_return(nil)
      expect(ResponsesTracking).to receive(:find_by).with(exercise_id: ongoing_psg2.id, user_id: user.id).and_return(tracking_details2)
      expect(ResponsesTracking).to receive(:remaining_time).with(ongoing_psg2.id, user.id).and_return(0)

      exercise_missed_for_candidate = Exercise.missed_by_candidate(user)

      expect(exercise_missed_for_candidate.count).to be(2)
      expect(exercise_missed_for_candidate).to contain_exactly(concluded_psg1, ongoing_psg2)
    end
    it 'should not get the exercise whose remaining time is not less than or equal to zero' do
      concluded_psg1 = double('Exercise 1', id: 11, duration: 4600)
      concluded_psg2 = double('Exercise 2', id: 12)
      ongoing_psg1 = double('Exercise 3', id: 13)
      ongoing_psg2 = double('Exercise 4', id: 14)
      tracking_details2 = double('Responses Tracking')

      user = double('User', id: 1)

      expect(Exercise).to receive(:concluded).and_return([concluded_psg1, concluded_psg2])
      expect(user).to receive(:exercises).and_return([concluded_psg2])
      expect(Exercise).to receive(:ongoing).and_return([ongoing_psg1, ongoing_psg2])
      expect(ResponsesTracking).to receive(:find_by).with(exercise_id: ongoing_psg1.id, user_id: user.id).and_return(nil)
      expect(ResponsesTracking).to receive(:find_by).with(exercise_id: ongoing_psg2.id, user_id: user.id).and_return(tracking_details2)
      expect(ResponsesTracking).to receive(:remaining_time).with(ongoing_psg2.id, user.id).and_return(10)

      exercise_missed_for_candidate = Exercise.missed_by_candidate(user)

      expect(exercise_missed_for_candidate.count).to be(1)
      expect(exercise_missed_for_candidate).to contain_exactly(concluded_psg1)
    end
    it 'should not get the exercise whose response is already submitted' do
      concluded_psg1 = double('Exercise 1', id: 11, duration: 4600)
      concluded_psg2 = double('Exercise 2', id: 12)
      ongoing_psg1 = double('Exercise 3', id: 13)
      ongoing_psg2 = double('Exercise 4', id: 14)
      tracking_details2 = double('Responses Tracking')

      user = double('User', id: 1)

      expect(Exercise).to receive(:concluded).and_return([concluded_psg1, concluded_psg2])
      expect(user).to receive(:exercises).and_return([concluded_psg2, ongoing_psg2])
      expect(Exercise).to receive(:ongoing).and_return([ongoing_psg1, ongoing_psg2])
      expect(ResponsesTracking).to receive(:find_by).with(exercise_id: ongoing_psg1.id, user_id: user.id).and_return(nil)
      expect(ResponsesTracking).to receive(:find_by).with(exercise_id: ongoing_psg2.id, user_id: user.id).and_return(tracking_details2)
      expect(ResponsesTracking).to receive(:remaining_time).with(ongoing_psg2.id, user.id).and_return(0)

      exercise_missed_for_candidate = Exercise.missed_by_candidate(user)

      expect(exercise_missed_for_candidate.count).to be(1)
      expect(exercise_missed_for_candidate).to contain_exactly(concluded_psg1)
    end
  end

  describe '#attended_exercise_by_candidate' do
    context 'get all attended exercises with response' do
      it 'should belongs to the logged candidate ' do
        exercise1 = double('Exercise', id: 11)

        response1 = double('Response', id: 1, exercise_id: 11)

        user = double('User', exercises: [exercise1], responses: [response1])

        attempted_by_candidate = Exercise.attempted_by_candidate(user)

        expect(attempted_by_candidate).to eq([{ exercise: exercise1, response: response1 }])
      end

      it 'should get empty if attempted exercise is zero ' do
        user = double('User', exercises: [], responses: [])

        attempted_by_candidate = Exercise.attempted_by_candidate(user)

        expect(attempted_by_candidate).to be_empty
      end
    end
  end
end
