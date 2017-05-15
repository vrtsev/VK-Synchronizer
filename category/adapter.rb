class Synchronizer::Category::Adapter < Synchronizer::Adapter
  def initialize(object, token)
    @category = object
    @token = token
    @synchronizer = Synchronizer::Category::Api.new(@token, @category)
  end

  def validate_object
    @category.synchronizable?
  end

  def check_existance
    return FailedStatus.new(
      'Синхронизации обьекта не зарегистрированы', @category
    ) unless @category.social_network_categories.vk.present?
    @id = @category.social_network_categories.vk.attrs['market_album_id']
    request = @synchronizer.get(@id) unless @id.nil?

    handle_response(request, @id) { '[PROC][Category::Adapter] Завершение процедуры проверки существующих синхронизаций' }
  end

  def create_object
    photo = upload_photo
    request = @synchronizer.add(photo)
    @category.social_network_categories.create \
      social_network: SocialNetwork.vk,
      parent_id: nil,
      status: :synchronized,
      attrs: request.attrs,
      sync_time: Time.now

    handle_response(request.present?, request.attrs) { '[PROC][Category::Adapter] Завершение процедуры создания обьекта ' }
  end

  def update_object
    photo = upload_photo
    request = @synchronizer.edit(@id, photo)
    @category.social_network_categories.vk.update \
      parent: nil,
      sync_time: Time.now

    handle_response(request, @id) { '[PROC][Category::Adapter] Завершение процедуры обновления ' }
  end

  private

  def upload_photo
    photo = @synchronizer.photo_uploader \
      :main,
      @category.image.current_path
    photo.attrs.first['id']
  end
end
