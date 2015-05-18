module EventBuilders
  def gen_user_id
    Faker::Internet.password(20)
  end

  def gen_video_id
    (Time.now.to_f * 1000).to_i.to_s
  end

  def event_data(sender_id, receiver_id, video_id)
    digest = Digest::MD5.new.update(sender_id + receiver_id + video_id)
    { sender_id: sender_id,
      receiver_id: receiver_id,
      video_filename: "#{sender_id}-#{receiver_id}-#{digest}",
      video_id: video_id }
  end

  def send_video(data)
    create :event, :video_s3_uploaded, data: data
  end

  def receive_video(data)
    create :video_kvstore_received_event do |e|
      e.initiator_id = data[:sender_id]
      e.target_id = data[:video_filename]
      e.data = data
    end
    create :video_notification_received_event do |e|
      e.initiator_id = data[:sender_id]
      e.target_id = data[:video_filename]
      e.data = data
    end
  end

  def download_video(data)
    create :video_kvstore_downloaded_event do |e|
      e.initiator_id = data[:sender_id]
      e.target_id = data[:video_filename]
      e.data = data
    end
    create :video_notification_downloaded_event do |e|
      e.initiator_id = data[:sender_id]
      e.target_id = data[:video_filename]
      e.data = data
    end
  end

  def view_video(data)
    create :video_kvstore_viewed_event do |e|
      e.initiator_id = data[:sender_id]
      e.target_id = data[:video_filename]
      e.data = data
    end
    create :video_notification_viewed_event do |e|
      e.initiator_id = data[:sender_id]
      e.target_id = data[:video_filename]
      e.data = data
    end
  end
end
