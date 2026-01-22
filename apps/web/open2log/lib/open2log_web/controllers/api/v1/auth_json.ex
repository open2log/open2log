defmodule Open2logWeb.API.V1.AuthJSON do
  alias Open2log.Accounts.User

  def auth_response(%{user: user, token: token}) do
    %{
      token: token,
      user: user_data(user)
    }
  end

  def error(%{changeset: changeset}) do
    %{
      error: "Validation failed",
      errors: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
    }
  end

  defp user_data(%User{} = user) do
    %{
      id: user.id,
      email: user.email,
      status: user.status,
      member_since: user.member_since,
      bank_reference: user.bank_reference,
      created_at: user.inserted_at
    }
  end

  defp translate_error({msg, opts}) do
    Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
      opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
    end)
  end
end
