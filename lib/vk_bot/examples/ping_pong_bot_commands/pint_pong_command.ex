defmodule VkBot.Examples.PingPongCommand do
  use VkBot.CommandsManager

  defcommand _event, on_text: "/ping", only_admin: true, in: :chat do
    {:ok, "pong"}
  end
end
