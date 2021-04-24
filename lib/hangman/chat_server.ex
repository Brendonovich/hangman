defmodule Hangman.ChatServer do
  use GenServer

  alias Hangman.PubSub

  defmodule State do
    defstruct(
      host: "irc.chat.twitch.tv",
      port: 80,
      username: String.downcase(Application.fetch_env!(:hangman, :twitch_username)),
      token: Application.fetch_env!(:hangman, :twitch_token),
      client: nil
    )
  end

  def handle_info({:connected, _port, _state}, state) do
    IO.inspect("Logging in to twitch with username #{state.username} and token #{state.token}")

    ExIRC.Client.logon(
      state.client,
      state.token,
      state.username,
      state.username,
      state.username
    )

    {:noreply, state}
  end

  def handle_info(:logged_in, state) do
    ExIRC.Client.join(state.client, "##{state.username}")
    broadcast(state, {:connection, :connected})

    {:noreply, state}
  end

  def handle_info({:received, msg, _conn, _channel}, state) do
    broadcast(state, {:message, msg})
    {:noreply, state}
  end

  def handle_info(:disconnected, state) do
    broadcast(state, {:connection, :disconnected})
    connect(state)
    {:noreply, state}
  end

  def handle_info(_info, state) do
    {:noreply, state}
  end

  def start_link(name: name) do
    {:ok, client} = ExIRC.start_link!()
    GenServer.start_link(__MODULE__, %{%State{} | client: client}, name: name)
  end

  def init(state) do
    ExIRC.Client.add_handler(state.client, self())
    connect(state)
    {:ok, state}
  end

  defp broadcast(state, value), do: Phoenix.PubSub.broadcast!(PubSub, "chat:#{state.username}", value)

  defp connect(state), do: ExIRC.Client.connect!(state.client, state.host, state.port)
end