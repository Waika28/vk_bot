defmodule VkBot.Examples.PingPongBot do
  use VkBot

  alias VkBot.Examples.PingPongCommand

  defcommands [
    PingPongCommand
  ]
end
