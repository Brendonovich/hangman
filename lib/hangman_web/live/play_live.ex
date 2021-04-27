defmodule HangmanWeb.PlayLive do
  use Phoenix.HTML
  use HangmanWeb, :live_view

  alias Hangman.{Game, ChatServer}

  @impl true
  def mount(_params, session, socket) do
    %{
      "current_user" => username,
      "access_token" => token
    } = session

    Phoenix.PubSub.subscribe(Hangman.PubSub, "chat:#{username}")

    case Phoenix.LiveView.connected?(socket) do
      true ->
        case Registry.lookup(Hangman.GameRegistry, username) do
          [] ->
            DynamicSupervisor.start_child(
              Hangman.GameSupervisor,
              {ChatServer, name: via_tuple(username), username: username, token: token}
            )

          _ ->
            nil
        end

        {:ok,
         assign(socket,
           mounted: true,
           game: Game.new_game(),
           twitch_username: username
         )}

      false ->
        {:ok, assign(socket, mounted: false)}
    end
  end

  @impl true
  def handle_event("guess_letter", %{"value" => letter}, socket),
    do: guess_letter(letter, socket)

  @impl true
  def handle_event("new_game", _args, socket) do
    {:noreply, assign(socket, game: Game.new_game())}
  end

  @impl true
  def handle_info(msg = %{type: "connection"}, socket) do
    case msg.value do
      :connected -> {:noreply, assign(socket, status: :connected)}
      _ -> {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:message, "!guess " <> letter}, socket) do
    guess_letter(String.first(letter), socket)
  end

  @impl true
  def handle_info(_info, socket) do
    {:noreply, socket}
  end

  defp guess_letter(letter, %{assigns: %{game: game}} = socket),
    do: {:noreply, assign(socket, game: Game.guess_letter(game, letter))}

  defp via_tuple(name) do
    {:via, Registry, {Hangman.GameRegistry, name}}
  end
end
