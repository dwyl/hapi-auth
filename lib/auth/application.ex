defmodule Auth.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    RBAC.init_roles_cache(
      "https://dwylauth.herokuapp.com",
      AuthPlug.Token.client_id()
    )
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      Auth.Repo,
      # Start the endpoint when the application starts
      {Phoenix.PubSub, name: Auth.PubSub},
      AuthWeb.Endpoint
      # Starts a worker by calling: Auth.Worker.start_link(arg)
      # {Auth.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Auth.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  # Sadly this is untestable hence ignoring it.
  # coveralls-ignore-start
  def config_change(changed, _new, removed) do
    AuthWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  # coveralls-ignore-stop
end
