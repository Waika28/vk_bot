defmodule VkBot.Examples.PingPongCommand do
  import VkBot.CommandsManager

  require VkBot.CommandsManager

  defcommand _event, on_text: "/ping", only_admin: true, in: :chat do
    {:ok, "pong"}
  end
end
