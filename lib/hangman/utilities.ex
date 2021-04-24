defmodule Hangman.Utilities do
  def get_env(name) do
    case Application.get_env(:hangman, name) do
      {:ok, value} -> value
      _ -> nil
    end
  end
end
