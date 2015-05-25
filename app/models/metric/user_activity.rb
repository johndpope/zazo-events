class Metric::UserActivity < Metric::Base
  attr_accessor :user_id
  after_initialize :set_user_id
  validates :user_id, presence: true

  def generate
    Event.where('initiator_id = :user_id OR target_id = :user_id OR data::text LIKE :user_id_pattern',
                user_id: user_id, user_id_pattern: "%#{user_id}%").order(:triggered_at)
  end

  protected

  def set_user_id
    @user_id = attributes['user_id']
  end
end
