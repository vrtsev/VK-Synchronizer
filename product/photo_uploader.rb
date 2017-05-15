module Synchronizer::Product::PhotoUploader
  def self.included(klass)
    klass.class_eval do
      include Synchronizer::PhotoUploader
    end
  end

  private

  def get_upload_server(type)
    params = { group_id: self.class::OWNER_ID, main_photo: type == :main ? 1 : 0 }
    request = send_request('photos.getMarketUploadServer', params)['upload_url']
  end

  def save(request)
    params = {
      group_id: self.class::OWNER_ID,
      photo: request['photo'],
      server: request['server'],
      hash: request['hash'],
      crop_data: request['crop_data'],
      crop_hash: request['crop_hash']
    }
    request = send_request('photos.saveMarketPhoto', params)

    handle_response(request.present?, request) { '[Product::PhotoUploader] Сохранение загруженного изображения' }
  end
end
