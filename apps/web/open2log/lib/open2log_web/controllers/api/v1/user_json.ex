defmodule Open2logWeb.API.V1.UserJSON do
  alias Open2log.Accounts.User

  def show(%{user: user}) do
    %{data: data(user)}
  end

  defp data(%User{} = user) do
    %{
      id: user.id,
      email: user.email,
      membership_status: User.membership_status(user),
      inserted_at: user.inserted_at
    }
  end
end
