defmodule AuthWeb.AuthController do
  use AuthWeb, :controller

  @doc """
  `github_auth/2` handles the callback from GitHub Auth API redirect.
  """
  def github_handler(conn, %{"code" => code, "state" => state}) do
    {:ok, profile} = ElixirAuthGithub.github_auth(code)
    # handler(conn, profile, state)
    # IO.inspect(profile, label: "github profile")
    conn
    |> put_view(AuthWeb.PageView)
    |> render(:welcome_github, profile: profile)
  end




  @doc """
  `handler/3` responds to successful auth requests.
  if the state is defined, redirect to it.
  """
  def handler(conn, person, state) do
    case not is_nil(state) and state =~ "//" do
      true -> # redirect
        url = state <> "?jwt=this.is.amaze"
        conn
        # |> put_req_header("authorization", "MY.JWT.HERE")
        |> redirect(external: url)
        # |> halt()
      false -> # no state
        conn
        |> put_view(AuthWeb.PageView)
        |> render(:welcome_github, person: person)
    end
  end

  def redirect_to_referer_with_jwt(conn, referer, person) do
    IO.inspect(conn, label: "conn")
    IO.inspect(referer, label: "referer")
    IO.inspect(person, label: "person")
  end
end