defmodule VkBot.CommandsManager.Predicates do
  def predicate(request, predicates) do
    predicates
    |> Enum.map(fn x ->
      predicate_request(request, x)
    end)
    |> Enum.all?()
  end

  defp predicate_request(request, {:on_text, on_text}) do
    text = Map.fetch!(request.message, "text")

    text
    |> String.downcase()
    |> String.starts_with?(on_text)
  end

  defp predicate_request(request, {:in, :chat}) do
    %{"peer_id" => peer_id, "from_id" => from_id} = request.message

    peer_id != from_id
  end

  defp predicate_request(request, {:in, :pm}) do
    %{"peer_id" => peer_id, "from_id" => from_id} = request.message

    peer_id == from_id
  end

  defp predicate_request(_request, {:in, :all}) do
    :cont
  end

end
