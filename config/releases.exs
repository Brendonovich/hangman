# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
import Config
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

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

# raise """
# environment variable SECRET_KEY_BASE is missing.
# You can generate one by calling: mix phx.gen.secret
# """

config :hangman, HangmanWeb.Endpoint,
  http: [
    port: String.to_integer(System.get_env("PORT") || "4000"),
    transport_options: [socket_opts: [:inet6]]
  ],
  secret_key_base: secret_key_base

twitch_username =
  System.fetch_env("TWITCH_USERNAME") ||
    raise "environment variable TWITCH_USERNAME is missing."

twitch_token =
  System.fetch_env("TWITCH_TOKEN") ||
    raise "environment variable TWITCH_TOKEN is missing."

config :hangman,
  twitch_username: twitch_username,
  twitch_token: twitch_token

# ## Using releases (Elixir v1.9+)
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start each relevant endpoint:
#

config :hangman, HangmanWeb.Endpoint, server: true

#
# Then you can assemble a release by calling `mix release`.
# See `mix help release` for more information.