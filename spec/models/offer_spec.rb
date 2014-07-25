require 'rails_helper'

RSpec.describe Offer, type: :model do

  describe 'Associations' do
    it { should belong_to :created_by }
    it { should have_many :messages }
    it { should have_many :items }
  end

  describe 'Database Columns' do
    it { should have_db_column(:language).of_type(:string) }
    it { should have_db_column(:collection_contact_name).of_type(:string) }
    it { should have_db_column(:state).of_type(:string) }
    it { should have_db_column(:collection_contact_phone).of_type(:string) }
    it { should have_db_column(:origin).of_type(:string) }
    it { should have_db_column(:stairs).of_type(:boolean) }
    it { should have_db_column(:parking).of_type(:boolean) }
    it { should have_db_column(:estimated_size).of_type(:string) }
    it { should have_db_column(:notes).of_type(:text) }
    it { should have_db_column(:created_by_id).of_type(:integer) }
  end

end
