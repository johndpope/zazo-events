class Metric::MessagesStatusesBetweenUsers < Metric::Base
  attr_accessor :user_id, :friend_id
  after_initialize :set_attributes
  validates :user_id, :friend_id, presence: true

  def generate
    { outgoing: reduce(messages_between(user_id, friend_id)),
      incoming: reduce(messages_between(friend_id, user_id)) }
  end

  protected

  def reduce(messages)
    messages.each_with_object(initial) do |message, results|
      results[:sent] += 1
      results[:incomplete] += 1 if message.incomplete?
      results[:unviewed] += 1 if message.unviewed?
    end
  end

  def messages_between(sender_id, receiver_id)
    Message.all(sender_id: sender_id, receiver_id: receiver_id)
  end

  def initial
    { sent: 0, incomplete: 0, unviewed: 0 }
  end

  def set_attributes
    @user_id = attributes['user_id']
    @friend_id = attributes['friend_id']
  end
end
