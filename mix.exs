defmodule Auth.Mixfile do
  use Mix.Project

  def project do
    [app: :auth,
     version: "0.0.1",
     elixir: "~> 1.2",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: [
       "coveralls": :test,
       "coveralls.detail": :test,
       "coveralls.post": :test,
       "coveralls.html": :test
     ],
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps()]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {Auth, []},
    applications: [
      # phoenix defaults:
      :phoenix, :phoenix_pubsub, :phoenix_html,
      :cowboy, :logger, :gettext, :phoenix_ecto, :postgrex,
      # auth specific:
      :ueberauth, :ueberauth_identity,
      # email
      :bamboo,
      # password encryption/checking for :ueberauth_identity
      :comeonin,
    ]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [ # Phoenix core:
      {:phoenix, "~> 1.2.1"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.6"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},

      # Auth:
      {:ueberauth, "~> 0.4"},          # github.com/ueberauth/ueberauth
      {:ueberauth_identity, "~> 0.2"}, # github.com/ueberauth/ueberauth_identity

      # Email Sent by AWS SES see: https://git.io/vSuqc
      {:bamboo, "~> 0.7"},             # github.com/thoughtbot/bamboo
      {:bamboo_smtp, "~> 1.2.1"},      # github.com/fewlinesco/bamboo_smtp

      # Password Hashing
      {:comeonin, "~> 2.0"},           # github.com/riverrun/comeonin (bcrypt)

      # Dev/Test only:
      {:excoveralls, "~> 0.6", only: :test}, # for checking test coverage
      {:mock, "~> 0.2.0", only: :test}, # for testing email without sending any
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "test": ["ecto.create --quiet", "ecto.migrate", "test"]]
  end
end
