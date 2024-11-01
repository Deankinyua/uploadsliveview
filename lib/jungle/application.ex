defmodule Jungle.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      JungleWeb.Telemetry,
      Jungle.Repo,
      {DNSCluster, query: Application.get_env(:jungle, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Jungle.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Jungle.Finch},
      # Start a worker by calling: Jungle.Worker.start_link(arg)
      # {Jungle.Worker, arg},
      # Start to serve requests, typically the last entry
      JungleWeb.Endpoint,
      {Jungle.Periodically, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Jungle.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    JungleWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
