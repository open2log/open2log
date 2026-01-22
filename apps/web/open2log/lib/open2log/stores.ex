defmodule Open2log.Stores do
  @moduledoc """
  The Stores context - handles shops and locations.
  """

  import Ecto.Query
  alias Open2log.Repo
  alias Open2log.Stores.Shop

  @doc """
  Gets a shop by ID.
  """
  def get(id) do
    Repo.get(Shop, id)
  end

  @doc """
  Gets a shop by GERS ID.
  """
  def get_by_gers_id(gers_id) do
    Repo.get_by(Shop, gers_id: gers_id)
  end

  @doc """
  Lists all shops.
  """
  def list_all do
    Shop
    |> order_by([s], asc: s.name)
    |> Repo.all()
  end

  @doc """
  Lists shops by city.
  """
  def list_by_city(city) do
    Shop
    |> where([s], ilike(s.city, ^city))
    |> order_by([s], asc: s.name)
    |> Repo.all()
  end

  @doc """
  Lists shops by chain.
  """
  def list_by_chain(chain) do
    Shop
    |> where([s], s.chain == ^chain)
    |> order_by([s], asc: s.name)
    |> Repo.all()
  end

  @doc """
  Lists shops near a location within a radius.
  Uses simple bounding box query for now.
  """
  def list_nearby(latitude, longitude, radius_km) do
    # Approximate degrees for the bounding box
    # 1 degree latitude ≈ 111 km
    # 1 degree longitude ≈ 111 km * cos(latitude)
    lat_delta = radius_km / 111.0
    lon_delta = radius_km / (111.0 * :math.cos(latitude * :math.pi() / 180))

    min_lat = latitude - lat_delta
    max_lat = latitude + lat_delta
    min_lon = longitude - lon_delta
    max_lon = longitude + lon_delta

    Shop
    |> where([s], s.latitude >= ^min_lat and s.latitude <= ^max_lat)
    |> where([s], s.longitude >= ^min_lon and s.longitude <= ^max_lon)
    |> Repo.all()
    |> Enum.map(fn shop ->
      distance = haversine_distance(latitude, longitude, shop.latitude, shop.longitude)
      Map.put(shop, :distance_km, distance)
    end)
    |> Enum.filter(fn shop -> shop.distance_km <= radius_km end)
    |> Enum.sort_by(& &1.distance_km)
  end

  @doc """
  Creates a shop.
  """
  def create_shop(attrs) do
    %Shop{}
    |> Shop.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a shop.
  """
  def update_shop(%Shop{} = shop, attrs) do
    shop
    |> Shop.changeset(attrs)
    |> Repo.update()
  end

  # Haversine formula for distance calculation
  defp haversine_distance(lat1, lon1, lat2, lon2) do
    r = 6371 # Earth's radius in km

    dlat = deg_to_rad(lat2 - lat1)
    dlon = deg_to_rad(lon2 - lon1)

    a =
      :math.sin(dlat / 2) * :math.sin(dlat / 2) +
      :math.cos(deg_to_rad(lat1)) * :math.cos(deg_to_rad(lat2)) *
      :math.sin(dlon / 2) * :math.sin(dlon / 2)

    c = 2 * :math.atan2(:math.sqrt(a), :math.sqrt(1 - a))

    r * c
  end

  defp deg_to_rad(deg) do
    deg * :math.pi() / 180
  end
end
