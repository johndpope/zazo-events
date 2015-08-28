module EventBuilders
  def gen_hash
    Faker::Internet.password(20)
  end

  def gen_video_id
    (Time.now.to_f * 1000).to_i.to_s
  end

  def video_data(sender_id, receiver_id, video_id)
    digest = Digest::MD5.new.update(sender_id + receiver_id + video_id)
    { sender_id: sender_id,
      receiver_id: receiver_id,
      video_filename: "#{sender_id}-#{receiver_id}-#{digest}",
      video_id: video_id }
  end

  def invitation_data(inviter_id, invitee_id)
    { inviter_id: inviter_id, invitee_id: invitee_id }
  end

  def send_video(data)
    e = build :event, :video_s3_uploaded, initiator_id: data[:sender_id],
                                          target_id: data[:video_filename],
                                          data: data
    e.initiator = 'user'
    e.target = 'video'
    e.save
    e
  end

  def kvstore_receive_video(data)
    e = build :event, :video_kvstore_received,
              initiator_id: data[:sender_id],
              target_id: data[:video_filename],
              data: data
    e.initiator = 'user'
    e.target = 'video'
    e.save
    e
  end

  def notification_receive_video(data)
    e = build :event, :video_notification_received,
              initiator_id: data[:sender_id],
              target_id: data[:video_filename],
              data: data
    e.initiator = 'user'
    e.target = 'video'
    e.save
    e
  end

  def receive_video(data)
    [kvstore_receive_video(data), notification_receive_video(data)]
  end

  def kvstore_download_video(data)
    e = build :event, :video_kvstore_downloaded,
              initiator_id: data[:sender_id],
              target_id: data[:video_filename],
              data: data
    e.initiator = 'user'
    e.target = 'video'
    e.save
    e
  end

  def notification_download_video(data)
    e = build :event, :video_notification_downloaded,
              initiator_id: data[:sender_id],
              target_id: data[:video_filename],
              data: data
    e.initiator = 'user'
    e.target = 'video'
    e.save
    e
  end

  def download_video(data)
    [kvstore_download_video(data), notification_download_video(data)]
  end

  def kvstore_view_video(data)
    e = build :event, :video_kvstore_viewed,
              initiator_id: data[:sender_id],
              target_id: data[:video_filename],
              data: data
    e.initiator = 'user'
    e.target = 'video'
    e.save
    e
  end

  def notification_view_video(data)
    e = build :event, :video_notification_viewed,
              initiator_id: data[:sender_id],
              target_id: data[:video_filename],
              data: data
    e.initiator = 'user'
    e.target = 'video'
    e.save
    e
  end

  def view_video(data)
    [kvstore_view_video(data), notification_view_video(data)]
  end

  def receiver_video_flow(data)
    receive_video(data) + download_video(data) + view_video(data)
  end

  def video_flow(data)
    [send_video(data)] + receiver_video_flow(data)
  end

  def invite_at(user, at)
    create_user_event user, at, :user_invited
  end

  def register_at(user, at)
    create_user_event user, at, :user_registered
  end

  def verify_at(user, at)
    create_user_event user, at, :user_verified
  end

  def create_user_event(user, at, event)
    e = build :event, event, initiator_id: user
    e.initiator = 'user'
    e.triggered_at = at
    e.save
    e
  end
end

RSpec.configure do |config|
  config.include EventBuilders
end
