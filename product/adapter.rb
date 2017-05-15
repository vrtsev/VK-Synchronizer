class Synchronizer::Product::Adapter < Synchronizer::Adapter
  def initialize(object, token)
    @product = object
    @token = token
    @synchronizer = Synchronizer::Product::Api.new(@token, @product)
    @category = @product.category.social_network_categories.vk.take
  end

  def validate_object
    @product.synchronizable?
  end

  def check_existance
    return FailedStatus.new(
      'Синхронизации обьекта не зарегистрированы', @product
    ) unless @product.social_network_products.vk.present?
    @id = @product.social_network_products.vk.attrs['market_item_id']
    request = @synchronizer.get(@id) unless @id.nil?

    handle_response(request, @id) { '[PROC][Product::Adapter] Завершение процедуры проверки существующих синхронизаций' }
  end

  def create_object
    photo = upload_photo
    request = @synchronizer.add(photo)
    assign_album(request)
    social_product = @product.social_network_products.create \
      social_network: SocialNetwork.vk,
      social_network_category: @category,
      status: :synchronized,
      attrs: request.attrs,
      sync_time: Time.now

    handle_response(request.present?, request.attrs) { '[PROC][Product::Adapter] Завершение процедуры создания обьекта ' }
  end

  def update_object
    photo = upload_photo
    request = @synchronizer.edit(@id, photo)
    assign_album(request)
    @product.social_network_products.vk.update \
      social_network_category: @category,
      sync_time: Time.now

    handle_response(request, @id) { '[PROC][Product::Adapter] Завершение процедуры обновления ' }
  end

  private

  def upload_photo
    main = @synchronizer.photo_uploader(:main, @product.image.current_path).attrs.first['id']

    scope = @product.secondary_photos.map { |e| e.image.thumb.current_path }.map do |path|
      sleep 0.5
      @synchronizer.photo_uploader(:secondary, path).attrs
    end.map(&:first).map {|o| o['id']}.join(',')

    { main: main, secondary: scope }
  end

  def assign_album(request)
    album = Synchronizer::Category::Adapter.new(@product.category.parent, @token).check_existance
    return FailedStatus.new(
      'Произошла ошибка при добавлении обьекта в альбом', @product
    ) unless request.success? && album.success?

    @synchronizer.assign_album(album, request)
  end
end
