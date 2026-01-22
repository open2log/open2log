defmodule Open2log.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Open2logWeb.Telemetry,
      Open2log.Repo,
      {DNSCluster, query: Application.get_env(:open2log, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Open2log.PubSub},
      # Start a worker by calling: Open2log.Worker.start_link(arg)
      # {Open2log.Worker, arg},
      # Start to serve requests, typically the last entry
      Open2logWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Open2log.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    Open2logWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
