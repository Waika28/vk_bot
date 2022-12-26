defmodule VkBot.Response do
  alias VkBot.Resposne.Reply

  defstruct ~w[message reply reply?]a

  def new(message) do
    %__MODULE__{
      message: message,
      reply: Reply.new(Map.fetch!(message, "peer_id")),
      reply?: true
    }
  end

  def halt(%__MODULE__{} = response) do
    Map.put(response, :reply?, false)
  end

  def reply_message(%__MODULE__{} = response, text) do
    update_in(response.reply.message, fn _ -> text end)
  end
end
