class S3Record::FetchClientVersion
  attr_accessor :s3_record

  def initialize(s3_record)
    self.s3_record = s3_record
  end

  def do
    client_version = s3_metadata['client-version']
    client_version || :undefined
  rescue Exception => e
    Rollbar.error exception: e.class.name, message: e.message
    :undefined
  end

  private

  def s3_metadata
    params = s3_record.first['s3']
    bucket_name = params['bucket']['name']
    file_name   = params['object']['key']
    s3_client_instance.head_object(bucket: bucket_name, key: file_name).metadata
  end

  def s3_client_instance
    Aws::S3::Client.new access_key_id: Figaro.env.s3_access_key_id,
                        secret_access_key: Figaro.env.s3_secret_access_key
  end
end
