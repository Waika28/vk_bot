defmodule VkBot.Request do
  alias VkBot.Resposne.Reply

  defstruct ~w[message reply reply?]a

  def new(message) do
    %__MODULE__{
      message: message,
      reply: Reply.new(Map.fetch!(message, "peer_id")),
      reply?: true
    }
  end

  def halt(%__MODULE__{} = request) do
    Map.put(request, :reply?, false)
  end

  def reply_message(%__MODULE__{} = request, text) do
    update_in(request.reply.message, fn _ -> text end)
  end
end
