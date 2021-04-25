defmodule Hangman.Utilities do
  def get_env(name), do: Application.fetch_env!(:hangman, name)

  def decode_body(response),
    do:
      response
      |> Map.get(:body)
      |> Poison.decode!()

  def get_system_env(name),
    do:
      System.get_env(name) ||
        raise("environment variable #{name} is missing.")
end
