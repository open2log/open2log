defmodule Open2log.Products do
  @moduledoc """
  The Products context - handles products, prices, and matching.
  """

  import Ecto.Query
  alias Open2log.Repo
  alias Open2log.Products.{Product, Price, ProductMatch}

  # Products

  @doc """
  Gets a product by ID.
  """
  def get(id) do
    Repo.get(Product, id)
  end

  @doc """
  Gets a product by EAN barcode.
  """
  def get_by_ean(ean) do
    Repo.get_by(Product, ean: ean)
  end

  @doc """
  Searches products by name or brand.
  """
  def search(query, limit \\ 20) do
    search_term = "%#{query}%"

    Product
    |> where([p], ilike(p.name, ^search_term) or ilike(p.brand, ^search_term))
    |> limit(^limit)
    |> Repo.all()
  end

  @doc """
  Lists recently added products.
  """
  def list_recent(limit \\ 20) do
    Product
    |> order_by([p], desc: p.inserted_at)
    |> limit(^limit)
    |> Repo.all()
  end

  @doc """
  Creates a product.
  """
  def create_product(attrs) do
    %Product{}
    |> Product.changeset(attrs)
    |> Repo.insert()
  end

  # Prices

  @doc """
  Creates a price entry.
  """
  def create_price(attrs) do
    %Price{}
    |> Price.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Gets latest prices for a product.
  """
  def get_prices(product_id, limit \\ 10) do
    Price
    |> where([p], p.product_id == ^product_id)
    |> order_by([p], desc: p.inserted_at)
    |> limit(^limit)
    |> Repo.all()
  end

  @doc """
  Gets prices at a specific shop.
  """
  def get_prices_at_shop(shop_id, limit \\ 50) do
    Price
    |> where([p], p.shop_id == ^shop_id)
    |> order_by([p], desc: p.inserted_at)
    |> limit(^limit)
    |> preload(:product)
    |> Repo.all()
  end

  # Product Matching

  @doc """
  Creates or updates a product match vote.
  """
  def create_or_update_match(attrs) do
    vote_match(
      attrs.physical_product_id,
      attrs.online_product_id,
      attrs.user_id,
      attrs.vote
    )
  end

  @doc """
  Records a user's vote on whether two products match.
  """
  def vote_match(physical_product_id, online_product_id, user_id, vote) do
    attrs = %{
      physical_product_id: physical_product_id,
      online_product_id: online_product_id,
      user_id: user_id,
      vote: vote
    }

    %ProductMatch{}
    |> ProductMatch.changeset(attrs)
    |> Repo.insert(
      on_conflict: {:replace, [:vote, :updated_at]},
      conflict_target: [:physical_product_id, :online_product_id, :user_id]
    )
    |> case do
      {:ok, _match} ->
        # Update vote counts and match confidence
        update_match_confidence(physical_product_id, online_product_id)

      error ->
        error
    end
  end

  defp update_match_confidence(physical_id, online_id) do
    # Count votes
    match_count =
      ProductMatch
      |> where([m], m.physical_product_id == ^physical_id and m.online_product_id == ^online_id)
      |> where([m], m.vote == :match)
      |> Repo.aggregate(:count, :id)

    no_match_count =
      ProductMatch
      |> where([m], m.physical_product_id == ^physical_id and m.online_product_id == ^online_id)
      |> where([m], m.vote == :not_match)
      |> Repo.aggregate(:count, :id)

    total = match_count + no_match_count
    confidence = if total > 0, do: match_count / total, else: 0.0

    # Update the product's match confidence if this is the best match
    Product
    |> where([p], p.id == ^physical_id)
    |> Repo.update_all(set: [match_confidence: confidence, vote_count: total])

    {:ok, confidence}
  end

  @doc """
  Gets suggested matches for a product without EAN.
  """
  def get_suggested_matches(product_id, limit \\ 5) do
    product = get(product_id)

    if product && product.ean do
      []
    else
      # Find products with similar names that have EANs
      search_term = "%#{product.name}%"

      Product
      |> where([p], p.id != ^product_id)
      |> where([p], not is_nil(p.ean))
      |> where([p], ilike(p.name, ^search_term))
      |> limit(^limit)
      |> Repo.all()
    end
  end
end
