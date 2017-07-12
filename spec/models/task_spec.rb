require 'rails_helper'

describe Task do
  describe 'associations' do
    it { should have_many(:exercises).dependent(:destroy) }
  end

  describe 'validations ' do
    it { should validate_presence_of(:title) }

    it { should validate_presence_of(:text) }
  end
end
