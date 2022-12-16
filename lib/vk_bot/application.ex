defmodule VkBot.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {VkBot.LongpollServer, name: VkBot.LongpollServer}
      # Starts a worker by calling: VkBot.Worker.start_link(arg)
      # {VkBot.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: VkBot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
