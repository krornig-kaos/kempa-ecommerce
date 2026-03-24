defmodule KempaEcommerce.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      KempaEcommerceWeb.Telemetry,
      KempaEcommerce.Repo,
      {Phoenix.PubSub, name: KempaEcommerce.PubSub},
      # Start a worker by calling: KempaEcommerce.Worker.start_link(arg)
      # {KempaEcommerce.Worker, arg},
      # Start to serve requests, typically the last entry
      KempaEcommerceWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: KempaEcommerce.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    KempaEcommerceWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
