class Metric::UploadDuplications < Metric::Base
  def generate
    reduce(data)
  end

  protected

  def data
    Event.video_s3_uploaded
      .group("data->>'video_filename'")
      .having("COUNT(data->>'video_filename') > 1")
      .order("COUNT(data->>'video_filename') DESC")
      .count
  end

  def reduce(data)
    result = data.each_with_object(Hash.new(0)) do |(video_filename, _count), memo|
      sender = video_filename.split('-').first
      memo[sender] += 1
    end
    result = result.sort_by { |_sender_id, count| -count }
    result.map { |sender_id, count| { sender_id: sender_id, count: count } }
  end
end
