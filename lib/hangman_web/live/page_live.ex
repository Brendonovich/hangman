defmodule HangmanWeb.PageLive do
  use Phoenix.HTML
  use HangmanWeb, :live_view

  alias Hangman.Game

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, game: Game.new_game())}
  end

  @impl true
  def handle_event("guess_letter", %{"value" => letter}, socket) do
    {:noreply, assign(socket, game: Game.guess_letter(socket.assigns.game, letter))}
  end

  def handle_event("new_game", _args, socket) do
    {:noreply, assign(socket, game: Game.new_game())}
  end
end
