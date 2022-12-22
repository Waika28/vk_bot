defmodule VkBot.Attachment do
  @can_download ~w[photo audio audio_message doc sticker]

  defstruct ~w[type object url file ext can_download? gif_as_mp4]a

  def new(%{"type" => type} = attachment, opts \\ []) do
    object = attachment[type]

    %__MODULE__{
      type: String.to_atom(type),
      object: object,
      can_download?: type in @can_download,
      gif_as_mp4: Keyword.get(opts, :gif_as_mp4, false)
    }
  end

  def download(%__MODULE__{} = attachment) do
    attachment
    |> get_url()
    |> download_by_url()
  end

  defp download_by_url(%__MODULE__{can_download?: false} = attachment), do: attachment

  defp download_by_url(%__MODULE__{url: url} = attachment) do
    body =
      HTTPoison.request!(:get, url, "", [], follow_redirect: true)
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

  defp get_url(
         %__MODULE__{type: :doc, object: %{"ext" => "gif"} = object, gif_as_mp4: true} =
           attachment
       ) do
    url =
      object
      |> Map.fetch!("preview")
      |> Map.fetch!("video")
      |> Map.fetch!("src")

    attachment
    |> Map.put(:url, url)
    |> Map.put(:ext, "mp4")
  end

  defp get_url(%__MODULE__{type: :doc, object: object} = attachment) do
    attachment
    |> Map.put(:url, Map.fetch!(object, "url"))
    |> Map.put(:ext, Map.fetch!(object, "ext"))
  end

  defp get_url(%__MODULE__{type: :audio_message, object: object} = attachment) do
    attachment
    |> Map.put(:url, Map.fetch!(object, "link_mp3"))
    |> Map.put(:ext, "mp3")
  end

  defp get_url(%__MODULE__{type: :audio, object: object} = attachment) do
    attachment
    |> Map.put(:url, Map.fetch!(object, "url"))
    |> Map.put(:ext, "mp3")
  end

  defp get_url(%__MODULE__{can_download?: false} = attachment), do: attachment
end
