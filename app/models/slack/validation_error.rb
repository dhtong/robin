class Slack::ValidationError
  attr_accessor :block_id
  attr_accessor :message

  def initialize(block_id, message)
    @block_id = block_id
    @message = message
  end

  def to_json
    res = {}
    res[@block_id] = @message
    res
  end
end