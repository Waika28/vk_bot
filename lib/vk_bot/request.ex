defmodule VkBot.Request do
  alias VkBot.Request.Reply

  defstruct ~w[message reply reply?]a

  @type t :: %__MODULE__{
          message: map(),
          reply: Reply.t(),
          reply?: boolean
        }

  @spec new(map) :: __MODULE__.t()
  def new(message) do
    %__MODULE__{
      message: message,
      reply: Reply.new(Map.fetch!(message, "peer_id")),
      reply?: true
    }
  end

  @spec halt(__MODULE__.t()) :: __MODULE__.t()
  def halt(%__MODULE__{} = request) do
    Map.put(request, :reply?, false)
  end

  @spec reply_message(__MODULE__.t(), String.t(), Keyword.t()) :: __MODULE__.t()
  def reply_message(%__MODULE__{} = request, message \\ "", opts \\ []) do
    [{:message, message} | opts]
    |> Enum.reduce(request, fn {key, value}, req ->
      update_in(req.reply, &Reply.set_field(&1, key, value))
    end)
  end
end
