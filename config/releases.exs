# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
import Config
import Hangman.Utilities
# database_url =
#   System.get_env("DATABASE_URL") ||
#     raise """
#     environment variable DATABASE_URL is missing.
#     For example: ecto://USER:PASS@HOST/DATABASE
#     """

# config :hangman, Hangman.Repo,
#   # ssl: true,
#   url: database_url,
#   pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

config :hangman, HangmanWeb.Endpoint,
  http: [
    port: String.to_integer(System.get_env("PORT") || "4000"),
    transport_options: [socket_opts: [:inet6]]
  ]

config :hangman,
  twitch_client_id: get_system_env("TWITCH_CLIENT_ID"),
  twitch_client_secret: get_system_env("TWITCH_CLIENT_SECRET"),
  twitch_redirect_uri: get_system_env("TWITCH_REDIRECT_URI"),
  secret_key_base: get_system_env("SECRET_KEY_BASE")

config :hangman, HangmanWeb.Endpoint, server: true
