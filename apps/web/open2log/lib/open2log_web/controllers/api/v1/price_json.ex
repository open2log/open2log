defmodule Open2logWeb.API.V1.PriceJSON do
  alias Open2log.Products.Price

  def show(%{price: price}) do
    %{data: price_data(price)}
  end

  def error(%{changeset: changeset}) do
    %{
      error: "Validation failed",
      errors: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
    }
  end

  defp price_data(%Price{} = price) do
    %{
      id: price.id,
      product_id: price.product_id,
      shop_id: price.shop_id,
      price_cents: price.price_cents,
      currency: price.currency,
      unit_price_cents: price.unit_price_cents,
      comparison_unit: price.comparison_unit,
      source: price.source,
      scanned_at: price.scanned_at,
      valid_from: price.valid_from,
      valid_until: price.valid_until,
      created_at: price.inserted_at
    }
  end

  defp translate_error({msg, opts}) do
    Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
      opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
    end)
  end
end
