defmodule VkBot.LongpollServer do
  alias VkBot.Longpoll
  use GenStage

  @message_queue_limit 20

  def start_link(options \\ []) do
    GenStage.start_link(__MODULE__, nil, options)
  end

  def init(_init_arg) do
    send(self(), :init)
    {:producer, nil}
  end

  def handle_info(:init, nil) do
    {:noreply, [], Longpoll.new()}
  end

  def handle_demand(_demand, longpoll_data) do
    new_lp_data = Longpoll.wait_updates(longpoll_data)
    {:noreply, new_lp_data.updates, new_lp_data}
  end
end
