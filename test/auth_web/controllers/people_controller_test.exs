defmodule AuthWeb.PeopleControllerTest do
  use AuthWeb.ConnCase
  # @email System.get_env("ADMIN_EMAIL")

  test "GET /people displays list of people", %{conn: conn} do
    conn = admin_login(conn)
    |> get("/people")

    assert html_response(conn, 200) =~ "People Authenticated"
  end

  test "Attempt to GET /people not unathenticated", %{conn: conn} do
    conn = get(conn, "/people")
    assert conn.status == 302
  end


  test "Attempt to GET /people without admin role should 401", %{conn: conn} do
    wrong_person_data = %{
      email: "not_admin@gmail.com",
      auth_provider: "email",
      id: 42
    }

    Auth.Person.create_person(wrong_person_data)
    conn = AuthPlug.create_jwt_session(conn, wrong_person_data)

    conn = get(conn, "/people")
    assert conn.status == 401
  end

  test "AuthWeb.PeopleView.status_string/2" do
    statuses = [%{text: "verified", id: 1}]
    assert AuthWeb.PeopleView.status_string(1, statuses) == "verified"
  end

  test "AuthWeb.PeopleView.status_string/2 if status_id is nil" do
    assert AuthWeb.PeopleView.status_string(nil, []) == "none"
  end
end
