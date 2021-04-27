defmodule Hangman do
  alias Hangman.{ChatSupervisor, GameSupervisor}

  @moduledoc """
  Hangman keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def create_game(username, token) do
    if !ChatSupervisor.chat_exists?(username) do
      ChatSupervisor.create_chat(username, token)
    end

    {:ok, _pid, id} = GameSupervisor.create_game(username)
    id
  end
end
