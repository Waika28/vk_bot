defmodule VkBot.CommandsManager.Predicates do
  def predicate(response, predicates) do
    predicates
    |> Enum.map(fn x ->
      predicate_response(response, x)
    end)
    |> Enum.all?()
  end

  defp predicate_response(response, {:on_text, on_text}) do
    text = Map.fetch!(response.message, "text")

    text
    |> String.downcase()
    |> String.starts_with?(on_text)
  end

  defp predicate_response(response, {:in, :chat}) do
    %{"peer_id" => peer_id, "from_id" => from_id} = response.message

    peer_id != from_id
  end

  defp predicate_response(response, {:in, :pm}) do
    %{"peer_id" => peer_id, "from_id" => from_id} = response.message

    peer_id == from_id
  end

  defp predicate_response(_response, {:in, :all}) do
    :cont
  end

end
