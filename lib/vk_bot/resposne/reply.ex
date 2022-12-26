defmodule VkBot.Resposne.Reply do
  defstruct ~w[peer_id message attachments random_id]a

  def new(peer_id) do
    %__MODULE__{
      peer_id: peer_id,
      random_id: 0
    }
  end

  def set_message(%__MODULE__{}=reply, message) do
    Map.put(reply, :message, message)
  end
end
