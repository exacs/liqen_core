# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :liqen_core,
  ecto_repos: [LiqenCore.Repo]

# Configures the endpoint
config :liqen_core, LiqenCoreWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "SXjrJlsf+Mhg8QtHU9paOx8tuG6Tijel90RPr6/0L56RWshcdbqLF4JaupKj1S7G",
  render_errors: [view: LiqenCoreWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: LiqenCore.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :guardian, Guardian,
  allowed_algos: ["HS512"],
  verify_module: Guardian.JWT,
  issuer: "Liqen Core",
  ttl: { 30, :days },
  allowed_drift: 2000,
  verify_issuer: true,
  secret_key: "+OmRh0bvNg2cEYppvHGV3k2ZwwtYp56VtoiRqzbkZeMgHQpr9bN/cP7wPe4ysJjh",
  serializer: LiqenCore.Accounts.GuardianSerializer

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
