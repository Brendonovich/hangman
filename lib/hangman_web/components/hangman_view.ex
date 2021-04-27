defmodule HangmanWeb.HangmanViewComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
      <svg class="flex-shrink" viewBox="0 0 166 251" fill="none" xmlns="http://www.w3.org/2000/svg">
        <line y1="248.5" x2="153" y2="248.5" stroke="white" stroke-width="5"/>
        <line x1="33" y1="2.5" x2="124" y2="2.5" stroke="white" stroke-width="5"/>
        <line x1="32.5858" y1="56.5858" x2="85.5858" y2="3.58578" stroke="white" stroke-width="4"/>
        <path d="M123.5 34L123.5 0" stroke="white" stroke-width="5"/>
        <line x1="33.5" y1="-1.08838e-07" x2="33.5" y2="248" stroke="white" stroke-width="5"/>
        <%= if @body_parts > 0 do %><circle cx="124" cy="61" r="28" stroke="white" stroke-width="4"/><% end %>
        <%= if @body_parts > 1 do %><line x1="123.5" y1="89" x2="123.5" y2="161" stroke="white" stroke-width="5"/><%  end %>
        <%= if @body_parts > 2 do %><line x1="124.687" y1="112.404" x2="82.6868" y2="124.404" stroke="white" stroke-width="5"/><%  end %>
        <%= if @body_parts > 3 do %><line y1="-2.5" x2="43.6807" y2="-2.5" transform="matrix(0.961524 0.274721 0.274721 -0.961524 124 110)" stroke="white" stroke-width="5"/><%  end %>
        <%= if @body_parts > 4 do %><line x1="122.768" y1="157.768" x2="89.7678" y2="190.768" stroke="white" stroke-width="5"/><%  end %>
        <%= if @body_parts > 5 do %><line x1="122.768" y1="156.232" x2="155.768" y2="189.233" stroke="white" stroke-width="5"/><%  end %>
      </svg>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end
end
