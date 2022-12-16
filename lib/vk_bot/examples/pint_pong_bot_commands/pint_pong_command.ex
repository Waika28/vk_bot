defmodule VkBot.Examples.PingPongCommand do
  use VkBot.CommandsManager

  defcommand on_text: "/ping" do
    {:ok, "pong"}
  end
end
