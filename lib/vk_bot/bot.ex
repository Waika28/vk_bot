defmodule VkBot.Bot do
  alias VkBot.CommandsManager
  use GenServer

  defstruct ~w[module longpoll]a

  @in_test Application.compile_env(:vk_bot, :in_test, false)

  def start_link(opts \\ []) do
    bot_opts = Keyword.fetch!(opts, :bot_opts)
    GenServer.start_link(__MODULE__, struct!(__MODULE__, bot_opts), opts)
  end

  @impl true
  def init(bot) do
    unless @in_test do
      send(self(), :init_longpoll)
      send(self(), :process)
    end

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
