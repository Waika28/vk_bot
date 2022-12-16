defmodule VkBot.Bot do
  alias VkBot.CommandsManager
  alias VkBot.LongpollServer

  defmacro __using__(_opts) do
    quote do
      use CommandsManager
      use GenStage

      def start_link(options \\ []) do
        GenStage.start_link(__MODULE__, nil, options)
      end

      @impl true
      def init(_init_arg) do
        {:consumer, nil, subscribe_to: [{LongpollServer, max_demand: 1}]}
      end

      @impl true
      def handle_events(events, _from, _state) do
        Enum.each(events, &Task.start(fn -> apply(__MODULE__, :handle_event, [&1]) end))

        {:noreply, [], nil}
      end
    end
  end
end
