defmodule VkBot.Bot do
  alias VkBot.CommandsManager

  defmacro __using__(_opts) do
    quote do
      use CommandsManager
      use GenServer

      def start_link(options \\ []) do
        GenServer.start_link(__MODULE__, nil, options)
      end

      @impl true
      def init(_state) do
        send(self(), :init)
        send(self(), :process)
        {:ok, nil}
      end

      @impl true
      def handle_info(:init, nil) do
        {:noreply, VkBot.Longpoll.new()}
      end

      @impl true
      def handle_info(:process, state) do
        new_state = VkBot.Longpoll.wait_updates(state)

        new_state.updates
        |> Enum.each(&Task.start(fn -> apply(__MODULE__, :handle_event, [&1]) end))

        send(self(), :process)
        {:noreply, new_state}
      end
    end
  end
end
