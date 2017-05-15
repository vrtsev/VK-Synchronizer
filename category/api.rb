class Synchronizer::Category::Api < Synchronizer::Api
  include Synchronizer::Category::PhotoUploader

  def initialize(token, object)
    @token = token
    @category = object
  end

  def get(item_id)
    return false unless item_id
    params = { owner_id: "-#{OWNER_ID}", album_ids: "#{item_id}" }
    request = send_request('market.getAlbumById', params)

    handle_response(request['items'].present?, item_id) { '[Category::Api] Обьект найден на серверах ВК' }
  end

  def add(photo)
    params = {
      owner_id: "-#{OWNER_ID}",
      title: @category.name,
      photo_id: photo,
      main_album: 0
    }
    request = send_request('market.addAlbum', params)

    handle_response(request.present?, request) { '[Category::Api] Создан обьект на серверах ВК' }
  end

  def edit(item_id, photo)
    params = {
      owner_id: "-#{OWNER_ID}",
      album_id: item_id,
      title: @category.name,
      photo_id: photo,
      main_album: 0
    }
    request = send_request('market.editAlbum', params)

    handle_response(request.nonzero?, request) { '[Category::Api] Обновлен обьект на серверах ВК' }
  end
end
