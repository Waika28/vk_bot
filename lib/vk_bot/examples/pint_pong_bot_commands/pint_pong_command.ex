defmodule VkBot.Examples.PingPongCommand do
  use VkBot.CommandsManager

  defcommand _event, on_text: "/ping" do
    {:ok, "pong"}
  end
end
