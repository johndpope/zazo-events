require 'rails_helper'

RSpec.describe Event, type: :model do
  describe 'columns' do
    it { is_expected.to have_db_column(:name).of_type(:string) }
    it { is_expected.to have_db_column(:triggered_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:triggered_by).of_type(:string) }
    it { is_expected.to have_db_column(:initiator).of_type(:string) }
    it { is_expected.to have_db_column(:initiator_id).of_type(:string) }
    it { is_expected.to have_db_column(:target).of_type(:string) }
    it { is_expected.to have_db_column(:target_id).of_type(:string) }
    it { is_expected.to have_db_column(:raw_data).of_type(:text) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:triggered_at) }
    it { is_expected.to validate_presence_of(:triggered_by) }
    it { is_expected.to validate_presence_of(:initiator) }
    it { is_expected.to validate_presence_of(:initiator_id) }

    it { is_expected.to validate_inclusion_of(:triggered_by).in_array(%w(aws:s3 zazo:api zazo:ios zazo:android)) }
  end
end
