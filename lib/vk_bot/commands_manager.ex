defmodule VkBot.CommandsManager do
  alias VkBot.Request
  alias VkBot.CommandsManager.Permissions
  alias VkBot.CommandsManager.Predicates

  defdelegate reply_message(request, text), to: Request

  def handle_event(module, event) do
    request =
      event
      |> Map.fetch!("object")
      |> Map.fetch!("message")
      |> VkBot.Request.new()

    case Enum.find(commands_list(module), :not_found, &command_predicate(&1, request)) do
      :not_found ->
        nil

      command_module ->
        command_handle(command_module, request)
        |> handle_request()
    end
  end

  defp commands_list(bot_module) do
    apply(bot_module, :commands, [])
  end

  defp command_predicate(command_module, request) do
    apply(command_module, :predicate, [request])
  end

  defp command_handle(command_module, request) do
    apply(command_module, :handle_event, [request])
  end

  defmacro defcommand(arg, opts, do: body) do
    predicates = Keyword.fetch!(opts, :predicate)
    permissions = Keyword.get(opts, :permissions, [])

    quote do
      def predicate(request) do
        Predicates.predicate(request, unquote(predicates))
      end

      def handle_event(unquote(arg)) do
        case Permissions.check_permissions(unquote(arg), unquote(permissions)) do
          :cont -> unquote(body)
          {:halt, request} -> request
        end
      end
    end
  end

  @spec handle_request(Request.t()) :: map()
  def handle_request(%Request{reply: reply, reply?: true}) do
    VkBot.Api.exec_method("messages.send", reply)
  end

  def handle_request(_request), do: nil
end
