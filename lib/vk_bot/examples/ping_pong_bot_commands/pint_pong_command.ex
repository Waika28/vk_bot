defmodule VkBot.Examples.PingPongCommand do
  import VkBot.CommandsManager

  require VkBot.CommandsManager

  defcommand request,
    predicate: [on_text: "/ping", in: :chat],
    permissions: [only_admin: true] do
    reply_message(request, message: "pong")
  end
end
