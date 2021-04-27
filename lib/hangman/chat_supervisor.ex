defmodule Hangman.ChatSupervisor do
  use DynamicSupervisor

  alias Hangman.ChatServer

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @doc """
  Creates a Chat server given the name under this dynamic supervisor.
  As the `ChatServer` stops when there are no players in the process anymore, we don't want that
  this Supervisor starts it after this process is finished. Because that the process is started
  using `restart: :temporary`.
  """
  def create_chat(username, token) do
    child_spec = %{
      id: ChatServer,
      start: {ChatServer, :start_link, [username, token]},
      restart: :temporary
    }

    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  @doc """
  Checks if there is a `ChatServer` process running with the given name.
  """
  def chat_exists?(chat_name) do
    case Registry.lookup(:chat_server_registry, chat_name) do
      [] -> false
      _ -> true
    end
  end
end
