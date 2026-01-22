defmodule Open2logWeb.API.V1.ProductMatchController do
  use Open2logWeb, :controller

  alias Open2log.Products

  action_fallback Open2logWeb.FallbackController

  def vote(conn, %{"id" => product_id, "online_product_id" => online_id, "vote" => vote}) do
    user = conn.assigns.current_user

    attrs = %{
      physical_product_id: product_id,
      online_product_id: online_id,
      user_id: user.id,
      vote: vote
    }

    with {:ok, match} <- Products.create_or_update_match(attrs) do
      conn
      |> put_status(:created)
      |> render(:show, match: match)
    end
  end
end
