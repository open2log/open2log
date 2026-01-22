defmodule Open2logWeb.API.V1.ShopJSON do
  alias Open2log.Stores.Shop

  def index(%{shops: shops}) do
    %{data: for(shop <- shops, do: shop_data(shop))}
  end

  def show(%{shop: shop}) do
    %{data: shop_data(shop)}
  end

  defp shop_data(%Shop{} = shop) do
    %{
      id: shop.id,
      gers_id: shop.gers_id,
      name: shop.name,
      chain: shop.chain,
      address: shop.address,
      city: shop.city,
      postal_code: shop.postal_code,
      country: shop.country,
      latitude: shop.latitude,
      longitude: shop.longitude,
      h3_index: shop.h3_index,
      opening_hours: shop.opening_hours
    }
  end
end
