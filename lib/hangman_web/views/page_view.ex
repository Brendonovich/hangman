defmodule HangmanWeb.PageView do
  use HangmanWeb, :view

  import Hangman.Utilities

  def twitch_auth_link() do
    "https://id.twitch.tv/oauth2/authorize" <>
      "?client_id=#{get_env(:twitch_client_id)}" <>
      "&redirect_uri=#{get_env(:twitch_redirect_uri)}" <>
      "&response_type=code" <>
      "&scope=chat:read"
  end
end
