defmodule VkBot.CommandsManager.Permissions do
  def check_permissions(request, permissions \\ []) do
    permissions
    |> Enum.reduce(:cont, fn
      permission, :cont -> check_permission(request, permission)
      _permission, {:halt, _request} = halted -> halted
    end)
  end

  defp check_permission(request, {:only_admin, true}) do
    %{"peer_id" => peer_id, "from_id" => from_id} = request.message

    is_admin =
      VkBot.Api.exec_method("messages.getConversationMembers", %{"peer_id" => peer_id})
      |> Map.fetch!("items")
      |> Enum.find(%{}, fn user -> Map.fetch!(user, "member_id") == from_id end)
      |> Map.get("is_admin", false)

    if is_admin,
      do: :cont,
      else:
        {:halt,
         VkBot.Request.reply_message(request, "Комманда доступа только для администраторов")}
  end
end
