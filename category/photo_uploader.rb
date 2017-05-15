module Synchronizer::Category::PhotoUploader
  def self.included(klass)
    klass.class_eval do
      include Synchronizer::PhotoUploader
    end
  end

  private

  def get_upload_server(type)
    params = { group_id: self.class::OWNER_ID }
    request = send_request('photos.getMarketAlbumUploadServer', params)['upload_url']
  end

  def save(request)
    params = {
      group_id: self.class::OWNER_ID,
      photo: request['photo'],
      server: request['server'],
      hash: request['hash'],
    }
    request = send_request('photos.saveMarketAlbumPhoto', params)

    handle_response(request.present?, request) { '[Category::PhotoUploader] Сохранение загруженного изображения' }
  end
end
