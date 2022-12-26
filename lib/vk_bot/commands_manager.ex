defmodule VkBot.CommandsManager do
  @default_options %{only_admin: false, in: :pm}

  def handle_event(module, event) do
    case Enum.find(apply(module, :commands, []), :not_found, &apply(&1, :predicate, [event])) do
      :not_found ->
        nil

      command ->
        apply(command, :handle_event, [event])
        |> handle_response(event)
    end
  end

  defmacro defcommand(arg, opts, do: body) do
    quote do
      def predicate(event) do
        VkBot.CommandsManager.predicate(event, unquote(opts))
      end

      def handle_event(unquote(arg)) do
        unquote(body)
      end
    end
  end

  def predicate(event, opts) do
    opts = Enum.into(opts, @default_options)

    [
      &predicate_on_text/2,
      &predicate_only_admin/2,
      &predicate_in/2
    ]
    |> Enum.map(fn fun -> fun.(event, opts) end)
    |> Enum.all?()
  end

  defp predicate_on_text(event, %{on_text: on_text}) do
    text = fetch_text(event)

    text
    |> String.downcase()
    |> String.starts_with?(on_text)
  end

  defp predicate_on_text(_event, _opts), do: true

  defp predicate_only_admin(event, %{only_admin: true}) do
    %{"peer_id" => peer_id, "from_id" => from_id} = fetch_message(event)

    VkBot.Api.exec_method("messages.getConversationMembers", %{"peer_id" => peer_id})
    |> Map.fetch!("items")
    |> Enum.find(%{}, fn user -> Map.fetch!(user, "member_id") == from_id end)
    |> Map.get("is_admin", false)
  end

  defp predicate_only_admin(_event, _opts), do: true

  defp predicate_in(event, %{in: :chat}) do
    %{"peer_id" => peer_id, "from_id" => from_id} = fetch_message(event)

    peer_id != from_id
  end

  defp predicate_in(event, %{in: :pm}) do
    %{"peer_id" => peer_id, "from_id" => from_id} = fetch_message(event)

    peer_id == from_id
  end

  defp predicate_in(_event, _opts), do: true

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
