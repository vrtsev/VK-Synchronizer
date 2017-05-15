module Synchronizer::PhotoUploader
  def photo_uploader(type, path)
    server_url = get_upload_server(type)
    request = send_photo(server_url, path)
    save(request)
  end

  private

  def send_photo(server_url, path)
    request = RestClient.post server_url, photo: File.new(path)
    JSON.parse(request)
  end
end
