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
    create :event, :video_s3_uploaded, data: data
  end

  def receive_video(data)
    result = []
    e = build :event, :video_kvstore_received,
              initiator_id: data[:sender_id],
              target_id: data[:video_filename],
              data: data
    e.initiator = 'user'
    e.target = 'video'
    e.save && result << e
    e = build :event, :video_notification_received,
              initiator_id: data[:sender_id],
              target_id: data[:video_filename],
              data: data
    e.initiator = 'user'
    e.target = 'video'
    e.save && result << e
    result
  end

  def download_video(data)
    result = []
    e = build :event, :video_kvstore_downloaded,
              initiator_id: data[:sender_id],
              target_id: data[:video_filename],
              data: data
    e.initiator = 'user'
    e.target = 'video'
    e.save && result << e
    e = build :event, :video_notification_downloaded,
              initiator_id: data[:sender_id],
              target_id: data[:video_filename],
              data: data
    e.initiator = 'user'
    e.target = 'video'
    e.save && result << e
    result
  end

  def view_video(data)
    result = []
    e = build :event, :video_kvstore_viewed,
              initiator_id: data[:sender_id],
              target_id: data[:video_filename],
              data: data
    e.initiator = 'user'
    e.target = 'video'
    e.save && result << e
    e = build :event, :video_notification_viewed,
              initiator_id: data[:sender_id],
              target_id: data[:video_filename],
              data: data
    e.initiator = 'user'
    e.target = 'video'
    e.save && result << e
    result
  end

  def receiver_video_flow(data)
    receive_video(data) + download_video(data) + view_video(data)
  end

  def video_flow(data)
    [send_video(data)] + receiver_video_flow(data)
  end
end

RSpec.configure do |config|
  config.include EventBuilders
end
