defmodule VkBot.Longpoll do
  defstruct ~w[key server ts url updates response valid]a

  @type t :: %__MODULE__{
          key: String.t(),
          server: String.t(),
          ts: String.t(),
          url: String.t() | nil,
          response: map() | nil,
          updates: list(),
          valid: boolean()
        }

  @group_id Application.compile_env!(:vk_bot, :group_id)

  alias VkBot.Api

  @spec new :: t
  def new() do
    Api.exec_method(
      "groups.getLongPollServer",
      %{"group_id" => @group_id}
    )
    |> parse_vk_response_to_struct()
  end

  def new(server, key, ts, updates) do
    %__MODULE__{
      key: key,
      server: server,
      ts: ts,
      valid: true,
      updates: updates
    }
  end

  @spec parse_vk_response_to_struct(map) :: t()
  def parse_vk_response_to_struct(response)

  def parse_vk_response_to_struct(%{"key" => key, "server" => server, "ts" => ts}) do
    %__MODULE__{
      key: key,
      server: server,
      ts: ts,
      valid: true,
      updates: []
    }
  end

  @spec wait_updates(t()) :: t()
  def wait_updates(longpoll_data) do
    longpoll_with_response =
      longpoll_data
      |> build_url()
      |> wait_response()

    if longpoll_with_response.valid do
      handle_response(longpoll_with_response)
    else
      new()
    end
  end

  @spec build_url(t()) :: t()
  def build_url(%__MODULE__{key: key, server: server, ts: ts} = longpoll_data) do
    longpoll_data
    |> Map.put(:url, "#{server}?act=a_check&key=#{key}&ts=#{ts}&wait=25")
  end

  @spec wait_response(t()) :: t()
  def wait_response(%__MODULE__{url: url} = longpoll_data) do
    longpoll_data
    |> Map.put(:response, Api.send_request(url))
  end

  @spec handle_response(t()) :: t()
  def handle_response(%__MODULE__{response: %{"failed" => 1, "ts" => new_ts}} = longpoll_data) do
    longpoll_data
    |> Map.put(:ts, new_ts)
  end

  def handle_response(%__MODULE__{response: %{"failed" => _error_num}} = longpoll_data) do
    longpoll_data
    |> Map.put(:valid, false)
  end

  def handle_response(
        %__MODULE__{response: %{"updates" => updates, "ts" => new_ts}} = longpoll_data
      ) do
    new(longpoll_data.server, longpoll_data.key, new_ts, updates)
  end
end
