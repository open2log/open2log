defmodule Open2logWeb.PageController do
  use Open2logWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
