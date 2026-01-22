defmodule Open2logWeb.API.V1.ShopController do
  use Open2logWeb, :controller

  alias Open2log.Stores

  action_fallback Open2logWeb.FallbackController

  def index(conn, params) do
    shops =
      case params do
        %{"city" => city} ->
          Stores.list_by_city(city)

        %{"chain" => chain} ->
          Stores.list_by_chain(chain)

        _ ->
          Stores.list_all()
      end

    render(conn, :index, shops: shops)
  end

  def nearby(conn, %{"lat" => lat, "lon" => lon} = params) do
    latitude = String.to_float(lat)
    longitude = String.to_float(lon)
    radius_km = Map.get(params, "radius", "5") |> String.to_float()

    shops = Stores.list_nearby(latitude, longitude, radius_km)
    render(conn, :index, shops: shops)
  end

  def nearby(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "lat and lon parameters required"})
  end
end
