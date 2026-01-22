defmodule Open2log.Accounts do
  @moduledoc """
  The Accounts context - handles user registration, authentication, and management.
  """

  import Ecto.Query
  alias Open2log.Repo
  alias Open2log.Accounts.User

  @doc """
  Registers a new user. Users start on the waitlist.
  """
  def register_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Authenticates a user by email and password.
  """
  def authenticate_user(email, password) do
    user = Repo.get_by(User, email: email)

    cond do
      user && User.verify_password(user, password) ->
        {:ok, user}

      user ->
        # Prevent timing attacks
        Bcrypt.no_user_verify()
        {:error, :invalid_credentials}

      true ->
        Bcrypt.no_user_verify()
        {:error, :invalid_credentials}
    end
  end

  @doc """
  Gets a user by ID.
  """
  def get_user(id) do
    Repo.get(User, id)
  end

  @doc """
  Gets a user by email.
  """
  def get_user_by_email(email) do
    Repo.get_by(User, email: email)
  end

  @doc """
  Activates a user (moves from waitlist to active).
  """
  def activate_user(%User{} = user) do
    user
    |> Ecto.Changeset.change(status: :active, confirmed_at: DateTime.utc_now())
    |> Repo.update()
  end

  @doc """
  Makes a user an NGO member.
  """
  def make_member(%User{} = user) do
    user
    |> Ecto.Changeset.change(status: :member, member_since: DateTime.utc_now())
    |> Repo.update()
  end

  @doc """
  Lists users on the waitlist.
  """
  def list_waitlist do
    User
    |> where([u], u.status == :waitlist)
    |> order_by([u], asc: u.inserted_at)
    |> Repo.all()
  end

  @doc """
  Updates a user's profile.
  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.profile_changeset(attrs)
    |> Repo.update()
  end
end
