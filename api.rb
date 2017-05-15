class Synchronizer::Api
  OWNER_ID = 138920343.freeze
  CATEGORY_ID = '302'.freeze

  def initialize(token, object)
    raise NotImplementedError
  end

  def get(item_id)
    raise NotImplementedError
  end

  def add(photo)
    raise NotImplementedError
  end

  def edit(item_id, photo)
    raise NotImplementedError
  end

  private

  def send_request(method, **args)
    Vk.client.access_token = @token
    Vk.client.request(method, args)
  end

  def handle_response(condition, attrs = nil, &block)
    Rails.logger.info "\n#{block.call}\n"
    return Synchronizer::Adapter::SuccessStatus.new('Процедура завершена успешно', attrs) if condition
    Synchronizer::Adapter::FailedStatus.new(block.call, attrs)
  end
end
