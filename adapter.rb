class Synchronizer::Adapter
  FailedStatus = Struct.new(:message, :attrs) do
    def success?
      false
    end
  end

  SuccessStatus = Struct.new(:message, :attrs) do
    def success?
      true
    end
  end

  def initialize(object, user)
    raise NotImplementedError
  end

  def validate_object
    raise NotImplementedError
  end

  def synchronize!
    return FailedStatus.new('Ошибка валидации', @product.title) unless validate_object

    result = if check_existance.success?
      update_object
    else
      create_object
    end

    handle_response(result.success?, result.attrs) { '[SYNC][Adapter] Синхронизация успешно завершена' }
  rescue Vk::Error => error
    error = JSON.parse(error.message.gsub('=>', ':'))['error']
    FailedStatus.new('Ошибка синхронизации', error)
  end

  def check_existance
    raise NotImplementedError
  end

  def create_object
    raise NotImplementedError
  end

  def update_object
    raise NotImplementedError
  end

  private

  def upload_photo
    raise NotImplementedError
  end

  def handle_response(condition, attrs = nil, &block)
    Rails.logger.info "\n#{block.call}\n"
    if condition
      SuccessStatus.new('Процедура завершена успешно', attrs)
    else
      FailedStatus.new(block.call, attrs)
    end
  end
end