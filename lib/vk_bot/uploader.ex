defmodule VkBot.Uploader do
  alias VkBot.Api

  def upload_photo(filepath) do
    get_server()
    |> upload_photo(filepath)
    |> save_photo()
    |> convert_to_attachment_link()
  end

  defp get_server() do
    Api.exec_method("photos.getMessagesUploadServer")
    |> Map.fetch!("upload_url")
  end

  defp upload_photo(url, filepath) do
    HTTPoison.post!(url, {:multipart, [{:file, filepath}]})
    |> Map.fetch!(:body)
    |> Jason.decode!()
  end

  defp save_photo(photo_object) do
    Api.exec_method("photos.saveMessagesPhoto", photo_object)
    |> Enum.at(0)
  end

  defp convert_to_attachment_link(photo) do
    owner_id = Map.fetch!(photo, "owner_id")
    id = Map.fetch!(photo, "id")
    access_key = Map.fetch!(photo, "access_key")

    "photo#{owner_id}_#{id}_#{access_key}"
  end
end
