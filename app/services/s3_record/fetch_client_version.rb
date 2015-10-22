class S3Record::FetchClientVersion
  attr_accessor :s3_record

  def initialize(s3_record)
    self.s3_record = s3_record
  end

  def do
    s3_metadata['client-version'] || :undefined
  rescue Exception => e
    Rollbar.error exception: e.class.name, message: e.message
    :undefined
  end

  private

  def s3_metadata
    bucket_name = s3_record['s3']['bucket']['name']
    file_name   = s3_record['s3']['object']['key']
    s3_client_instance.head_object(bucket: bucket_name, key: file_name).metadata
  end

  def s3_client_instance
    Aws::S3::Client.new access_key_id: Figaro.env.s3_access_key_id,
                        secret_access_key: Figaro.env.s3_secret_access_key
  end
end