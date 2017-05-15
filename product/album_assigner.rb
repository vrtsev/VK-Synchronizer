module Synchronizer::Product::AlbumAssigner

  def assign_album(album, request)
    search_item = search(album.attrs, request.attrs['market_item_id'])
    assignee = Synchronizer::Product::Api.new(@token, @product)
    .add_to_album(album.attrs, request.attrs['market_item_id']) unless search_item.success?

    handle_response(assignee.success?, assignee.attrs) { '[PROC][Product::Adapter] Завершение процедуры добавления обьекта в альбом ' }
  end

  def search(album_id, item_id)
    params = {
      owner_id: "-#{self.class::OWNER_ID}",
      album_id: album_id,
      q: @product.title,
      count: 200
    }

    request = send_request('market.search', params)
    search = request['items'].find { |item| item['id'] == item_id }

    handle_response(search, search) { '[Product::Api] Проверка наличия обьекта в альбомах' }
  end

  def add_to_album(album_id, item_id)
    params = {
      owner_id: "-#{self.class::OWNER_ID}",
      item_id: item_id,
      album_ids: album_id
    }

    request = send_request('market.addToAlbum', params) #=> 1 или 0
    handle_response(request.nonzero?, item_id) { '[Product::Api] Добавление обьекта в альбом' }
  end
end
