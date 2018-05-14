defmodule Pokedex.UserController do
  use Pokedex.Web, :controller
  alias Pokedex.User
  alias Pokedex.Pokemon

  plug :authenticate when action in [:show]

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def index(conn, _params) do
    users = Repo.all(Pokedex.User)
    pokemon = Repo.all(Pokedex.Pokemon)
    render(conn, "index.html", users: users, pokedex: pokemon)
  end

  def show(conn, %{"id" => id}) do
    user = Repo.get(Pokedex.User, id)
    render(conn, "show.html", user: user)
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.registration_changeset(%User{}, user_params)
    case Repo.insert(changeset) do
      {:ok, user} ->
        conn
        |> Pokedex.Auth.login(user)
        |> put_flash(:info, "#{user.name} created! Run while you can...")
        |> redirect(to: pokemon_path(conn, :index))

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  defp authenticate(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "Check your privelege")
      |> redirect(to: page_path(conn, :index))
      |> halt()
    end
  end
end
