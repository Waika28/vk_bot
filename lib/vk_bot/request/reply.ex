defmodule VkBot.Request.Reply do

  @type t :: map()

  def new(peer_id) do
    %{
      peer_id: peer_id,
      random_id: 0
    }
  end

  def set_field(%{} = reply, key, value) do
    Map.put(reply, key, value)
  end

  def set_message(%{} = reply, message) do
    set_field(reply, :message, message)
  end
end
