defmodule VkBot.Bot do
  alias VkBot.CommandsManager
  use GenServer

  defstruct ~w[module longpoll]a

  def start_link(module, options \\ []) do
    GenServer.start_link(__MODULE__, %__MODULE__{module: module}, options)
  end

  @impl true
  def init(bot) do
    send(self(), :init_longpoll)
    send(self(), :process)
    {:ok, bot}
  end

  @impl true
  def handle_info(:init_longpoll, bot) do
    {:noreply, Map.put(bot, :longpoll, VkBot.Longpoll.new())}
  end

  @impl true
  def handle_info(:process, %__MODULE__{module: module, longpoll: longpoll}) do
    new_lp = VkBot.Longpoll.wait_updates(longpoll)

    new_lp.updates
    |> Enum.each(&Task.start(fn -> CommandsManager.handle_event(module, &1) end))

    send(self(), :process)
    {:noreply, %__MODULE__{module: module, longpoll: new_lp}}
  end
end
