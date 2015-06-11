class Metric::MessagesCountBetweenUsers < Metric::Base
  after_initialize :set_attributes

  attr_accessor :user_id, :friends_ids, :users_ids

  def generate
    results.as_json.map { |row| row.delete 'id'; row }
  end

  protected

  def results
    scope = Event.where(
      query_where,
      user_id, friends_ids,
      friends_ids, user_id
    )
    scope.name_overlap(%w(downloaded viewed))
      .group('receiver, sender')
      .select(query_select)
  end

  def query_where
    <<-SQL
      data->>'sender_id'     = ? AND
      data->>'receiver_id' IN (?) OR
      data->>'sender_id'   IN (?) AND
      data->>'receiver_id'   = ?
    SQL
  end

  def query_select
    <<-SQL
      data->>'sender_id'   as sender,
      data->>'receiver_id' as receiver,
      COUNT(DISTINCT data->>'video_filename')
    SQL
  end

  def set_attributes
    @user_id     = attributes['user_id']
    @friends_ids = attributes['friends_ids']
    @users_ids   = attributes['users_ids']
  end
end
