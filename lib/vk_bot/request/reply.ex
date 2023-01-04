defmodule VkBot.Request.Reply do
  @type t :: map()

  def new(peer_id) do
    %{
      peer_id: peer_id,
      random_id: 0
    }
  end

  def set_field(%{} = reply, :photo, filepath) do
    photo = VkBot.Uploader.upload_photo(filepath)

    Map.update(reply, :attachment, [photo], &List.insert_at(&1, 0, photo))
  end

  def set_field(%{} = reply, key, value) do
    Map.put(reply, key, value)
  end
end
