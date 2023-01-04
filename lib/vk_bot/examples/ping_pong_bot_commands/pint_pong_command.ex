defmodule VkBot.Examples.PingPongCommand do
  import VkBot.CommandsManager
  import VkBot.Request

  require VkBot.CommandsManager

  defcommand request,
    predicate: [on_text: "/ping", in: :chat],
    permissions: [only_admin: true] do
    reply_message(request, "pong", photo: "lib/vk_bot/examples/pong.png")
  end
end
