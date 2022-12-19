defmodule VkBot.Attachment do
  @can_download ~w[photo video audio doc sticker]

  defstruct ~w[type object url file]a

  def new(%{"type" => type} = attachment) when type in @can_download do
    object = attachment[type]

    %__MODULE__{
      type: String.to_atom(type),
      object: object
    }
  end

  def download(%__MODULE__{} = attachment) do
    attachment
    |> get_url()
    |> download_by_url()
  end

  defp download_by_url(%__MODULE__{url: url} = attachment) do
    body =
      HTTPoison.get!(url)
      |> Map.fetch!(:body)

    Map.put(attachment, :file, body)
  end

  defp get_url(%__MODULE__{type: :photo, object: object} = attachment) do
    url =
      object["sizes"]
      |> Enum.max_by(fn s -> s["width"] * s["height"] end)
      |> Map.fetch!("url")

    Map.put(attachment, :url, url)
  end

  defp get_url(%__MODULE__{type: :sticker, object: object} = attachment) do
    url =
      object["images"]
      |> Enum.max_by(fn s -> s["width"] * s["height"] end)
      |> Map.fetch!("url")

    Map.put(attachment, :url, url)
  end
end
