class Metric::UserActivity < Metric::Base
  def user_id
    options[:user_id] || fail('user_id is not set')
  end

  def generate
    Event.where('initiator_id = :user_id OR target_id = :user_id OR data::text LIKE :user_id_pattern',
                user_id: user_id, user_id_pattern: "%#{user_id}%").order(:triggered_at)
  end
end
