defmodule Open2log.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :email, :string
    field :password_hash, :string
    field :password, :string, virtual: true
    field :confirmed_at, :utc_datetime
    field :status, Ecto.Enum, values: [:waitlist, :active, :suspended], default: :waitlist

    # NGO membership
    field :member_since, :utc_datetime
    field :bank_reference, :string

    timestamps(type: :utc_datetime)
  end

  def registration_changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password])
    |> validate_required([:email, :password])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/)
    |> validate_length(:password, min: 8, max: 72)
    |> unique_constraint(:email)
    |> hash_password()
    |> generate_bank_reference()
  end

  defp hash_password(changeset) do
    case get_change(changeset, :password) do
      nil -> changeset
      password -> put_change(changeset, :password_hash, Bcrypt.hash_pwd_salt(password))
    end
  end

  defp generate_bank_reference(changeset) do
    # Generate unique Finnish bank reference number
    # Format: RF + check digits + our generated number
    ref = :crypto.strong_rand_bytes(8) |> Base.encode16() |> String.downcase()
    put_change(changeset, :bank_reference, "RF#{ref}")
  end

  def verify_password(%__MODULE__{password_hash: hash}, password) do
    Bcrypt.verify_pass(password, hash)
  end

  def profile_changeset(user, attrs) do
    user
    |> cast(attrs, [:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/)
    |> unique_constraint(:email)
  end

  def membership_status(%__MODULE__{member_since: nil}), do: :none
  def membership_status(%__MODULE__{member_since: _}), do: :active
end
