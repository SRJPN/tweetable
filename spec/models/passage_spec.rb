RSpec.describe Passage, type: :model do

  let(:passages) {
    [
        {
            title: 'Climate Change', text: 'climate change passage', start_time: DateTime.now, close_time: (DateTime.now+2), duration: '1'
        },

        {
            title: 'Person', text: 'person passage', start_time: DateTime.now, close_time: (DateTime.now+1), duration: '2'
        },

        {
            title: 'News', text: 'news passage', start_time: (DateTime.now-2), close_time: (DateTime.now-1), duration: '2'
        },
        {
            title: 'Program', text: 'program passage', start_time: (DateTime.now-3), close_time: (DateTime.now+1), duration: '2'
        },
        {
            title: 'Class', text: 'class passage', start_time: (DateTime.now-3), close_time: (DateTime.now-1), duration: '2'
        },
        {
            title: 'Computer', text: 'computer passage', start_time: (DateTime.now+3), close_time: (DateTime.now+7), duration: '2'
        },
        {
            title: 'Human', text: 'human passage', start_time: nil, close_time: nil, duration: '2'
        }
    ]

  }

  let(:users) {

    [
        {
            name: 'Kamal Hasan', admin: false, auth_id: '132271', image_url: 'http://graph.facebook.com/demo1'
        },
        {
            name: 'Vimal Hasan', admin: false, auth_id: '132273', image_url: 'http://graph.facebook.com/demo1'
        },
        {
            name: 'Rajanikanth', admin: false, auth_id: '132272', image_url: 'http://graph.facebook.com/demo2'
        }
    ]
  }

  let(:responses) { [
      {
          text: 'respose for Climate Changed', user_id: User.find_by(auth_id: '132271').id, passage_id: Passage.find_by(title: 'Climate Change').id
      },
      {
          text: 'respose for Climate Changed', user_id: User.find_by(auth_id: '132273').id, passage_id: Passage.find_by(title: 'Climate Change').id
      },
      {
          text: 'respose for Person', user_id: User.find_by(auth_id: '132271').id, passage_id: Passage.find_by(title: 'Person').id
      },
      {
          text: 'respose for Person', user_id: User.find_by(auth_id: '132273').id, passage_id: Passage.find_by(title: 'Person').id
      },
      {
          text: 'News Response', user_id: User.find_by(auth_id: '132273').id, passage_id: Passage.find_by(title: 'News').id
      }
  ]
  }

  before(:each) do
    @users = User.create(users)
    @passages = Passage.create(passages)
    @responses = Response.create(responses)
  end



  describe 'validations ' do

    it {should validate_presence_of(:title)}

    it {should validate_presence_of(:text)}

    it { should validate_numericality_of(:duration).is_greater_than(0) }

  end

  describe 'associations' do

    it{ should have_many(:responses).dependent(:destroy)}

  end


  describe 'open_passages' do
    it 'should get all open passages count to be three' do
      expect(Passage.open_passages.count).to be(3)
    end
    it 'should get all open passages titles' do
      opened_titles = Passage.open_passages.map(&:title)
      expect(opened_titles).to contain_exactly('Climate Change', 'Person', 'Program')
    end
  end

  describe 'draft_passages' do
    it 'should get all draft passages count to be three' do
      expect(Passage.draft_passages.count).to be(2)
    end
    it 'should get all open passages titles' do
      opened_titles = Passage.draft_passages.map(&:title)
      expect(opened_titles).to contain_exactly('Computer', 'Human')
    end
  end

  describe 'closed_passages' do
    it 'should get all closed passages count to be three' do
      expect(Passage.closed_passages.count).to be(2)
    end
    it 'should get all open passages titles' do
      opened_titles = Passage.closed_passages.map(&:title)
      expect(opened_titles).to contain_exactly('News', 'Class')
    end
  end

  describe 'open_for_candidate_passages' do
    it 'should get all open passages for the candidate which are not attempted by user count to be one' do
      user = User.find_by(auth_id: '132271')
      passage_open_for_candidate = Passage.open_for_candidate(user)
      expect(passage_open_for_candidate.count).to be(1)
      passage_titles = Passage.open_for_candidate(user).map(&:title)
      expect(passage_titles).to contain_exactly('Program')
    end
    it 'should get all open passages titles when the user has not attempted any open passages' do
      user = User.find_by(auth_id: '132272')
      passage_titles = Passage.open_for_candidate(user).map(&:title)
      expect(passage_titles).to contain_exactly('Climate Change','Person', 'Program')
    end
  end

  describe '#missed_by_candidate_passages' do
    it 'should get all missed passages for the candidate which are not attempted by user count to be one' do
      user = User.find_by(auth_id: '132273')
      passage_missed_by_candidate = Passage.missed_by_candidate(user)
      expect(passage_missed_by_candidate.count).to be(1)
      passage_titles = passage_missed_by_candidate.map(&:title)
      expect(passage_titles).to contain_exactly('Class')
    end
  end

  describe '#attended_passage_by_candidate' do
    context 'get all attended passges with response' do
      it 'should belongs to the logged candidate ' do

        passage1 = double('Passage',id:11)

        response1 = double('Response',id:1,passage_id:11)

        user = double('User', passages: [passage1], responses: [response1])

        attempted_by_candidate = Passage.attempted_by_candidate(user)

        expect(attempted_by_candidate).to eq([{passage:passage1,response:response1}])
      end

      it 'should get empty if attemted passage is zero ' do


        user = double('User', passages: [], responses: [])

        attempted_by_candidate = Passage.attempted_by_candidate(user)

        expect(attempted_by_candidate).to be_empty
      end
    end
  end
end
