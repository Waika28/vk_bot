defmodule VkBot.CommandsManager do
  defmacro __using__(_opts) do
    quote do
      require VkBot.CommandsManager
      import VkBot.CommandsManager
    end
  end

  defmacro defcommands(commands) when is_list(commands) do
    quote do
      def handle_event(event) do
        case Enum.find(unquote(commands), :not_found, &apply(&1, :predicate, [event])) do
          :not_found ->
            nil

          module ->
            apply(module, :handle_event, [event])
            |> handle_response(event)
        end
      end
    end
  end

  defmacro defcommand(arg, [on_text: text], do: body) do
    quote do
      def predicate(event) do
        text = fetch_text(event)

        text
        |> String.downcase()
        |> String.starts_with?(unquote(text))
      end

      def handle_event(unquote(arg)) do
        unquote(body)
      end
    end
  end

  def fetch_text(update) do
    update
    |> fetch_message()
    |> Map.fetch!("text")
  end

  def fetch_peer_id(update) do
    update
    |> fetch_message()
    |> Map.fetch!("peer_id")
  end

  def fetch_message(update) do
    update
    |> Map.fetch!("object")
    |> Map.fetch!("message")
  end

  def handle_response({:ok, text}, event) when is_binary(text) do
    peer_id = fetch_peer_id(event)
    VkBot.Api.exec_method("messages.send", %{
      "peer_id" => peer_id,
      "random_id" => 0,
      "message" => text
    })
  end
end
