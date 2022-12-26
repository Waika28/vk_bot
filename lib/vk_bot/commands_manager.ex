defmodule VkBot.CommandsManager do
  alias VkBot.Response
  alias VkBot.CommandsManager.Permissions
  alias VkBot.CommandsManager.Predicates

  defdelegate reply_message(response, text), to: Response

  def handle_event(module, event) do
    response =
      event
      |> Map.fetch!("object")
      |> Map.fetch!("message")
      |> VkBot.Response.new()

    case Enum.find(commands_list(module), :not_found, &command_predicate(&1, response)) do
      :not_found ->
        nil

      command_module ->
        command_handle(command_module, response)
        |> handle_response()
    end
  end

  defp commands_list(bot_module) do
    apply(bot_module, :commands, [])
  end

  defp command_predicate(command_module, response) do
    apply(command_module, :predicate, [response])
  end

  defp command_handle(command_module, response) do
    apply(command_module, :handle_event, [response])
  end

  defmacro defcommand(arg, opts, do: body) do
    predicates = Keyword.fetch!(opts, :predicate)
    permissions = Keyword.get(opts, :permissions, [])

    quote do
      def predicate(response) do
        Predicates.predicate(response, unquote(predicates))
      end

      def handle_event(unquote(arg)) do
        case Permissions.check_permissions(unquote(arg), unquote(permissions)) do
          :cont -> unquote(body)
          {:halt, response} -> response
        end
      end
    end
  end

  def handle_response(%Response{reply: reply, reply?: true}) do
    VkBot.Api.exec_method("messages.send", Map.from_struct(reply))
  end

  def handle_response(_response), do: nil
end
