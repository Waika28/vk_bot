defmodule VkBot.Attachments do
  def download(attachment) do
    attachment
    |> get_url()
    |> download_by_url()
  end

  defp download_by_url(%{"url" => url, "type" => type}) do
    body =
      HTTPoison.get!(url)
      |> Map.fetch!(:body)

    %{"file" => body, "type" => type}
  end

  defp fetch_object(attachment) do
    attachment[attachment["type"]]
  end

  defp get_url(%{"type" => "photo"} = attachment) do
    obj = fetch_object(attachment)

    url =
      obj["sizes"]
      |> Enum.max_by(fn s -> s["width"] * s["height"] end)
      |> Map.fetch!("url")

    %{"type" => "photo", "url" => url}
  end
end
