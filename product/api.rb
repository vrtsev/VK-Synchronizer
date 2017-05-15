class Synchronizer::Product::Api < Synchronizer::Api
  include Synchronizer::Product::PhotoUploader
  include Synchronizer::Product::AlbumAssigner

  def initialize(token, object)
    @token = token
    @product = object
  end

  def get(item_id)
    return false unless item_id
    params = { item_ids: "-#{OWNER_ID}_#{item_id}" }
    request = send_request('market.getById', params)

    handle_response(request['items'].present?, @id) { '[Product::Api] Поиск обьекта на серверах ВК' }
  end

  def add(photo)
    params = {
      owner_id: "-#{OWNER_ID}",
      name: @product.title,
      description: @product.description,
      category_id: CATEGORY_ID,
      price: @product.price,
      deleted: 0,
      main_photo_id: photo[:main],
      photo_ids: photo[:secondary]
    }
    request = send_request('market.add', params)

    handle_response(request.present?, request) { '[Product::Api] Создание обьекта на серверах ВК' }
  end

  def edit(item_id, photo)
    params = {
      owner_id: "-#{OWNER_ID}",
      item_id: item_id,
      name: @product.title,
      description: @product.description,
      category_id: CATEGORY_ID,
      price: @product.price,
      deleted: 0,
      main_photo_id: photo[:main],
      photo_ids: photo[:secondary]
    }
    request = send_request('market.edit', params)
    binding.pry
    handle_response(request.nonzero?, nil) { '[Product::Api] Обновление обьекта на серверах ВК' }
  end
end
