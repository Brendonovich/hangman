defmodule HangmanWeb.PageLive do
  use Phoenix.HTML
  use HangmanWeb, :live_view

  alias Hangman.{Game, ChatServer}

  @impl true
  def mount(_params, _session, socket) do
    name = "brendonovich"

    Phoenix.PubSub.subscribe(Hangman.PubSub, "chat:#{name}")

    case Phoenix.LiveView.connected?(socket) do
      true ->
        case Registry.lookup(Hangman.GameRegistry, name) do
          [] ->
            DynamicSupervisor.start_child(
              Hangman.GameSupervisor,
              {ChatServer, name: via_tuple(name)}
            )

          _ ->
            nil
        end

        {:ok,
         assign(socket,
           mounted: true,
           game: Game.new_game()
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
  def handle_info({:message, message}, socket) do
    guess_letter(String.first(message), socket)
  end

  @impl true
  def handle_info(_info, socket) do
    {:noreply, socket}
  end

  defp via_tuple(name) do
    {:via, Registry, {Hangman.GameRegistry, name}}
  end

  defp guess_letter(letter, %{assigns: %{game: game}} = socket),
    do: {:noreply, assign(socket, game: Game.guess_letter(game, letter))}
end
