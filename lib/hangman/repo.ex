defmodule Hangman.Repo do
  use Ecto.Repo,
    otp_app: :hangman,
    adapter: Ecto.Adapters.Postgres
end
