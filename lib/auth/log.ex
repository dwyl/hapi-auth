defmodule Auth.Log do
  @moduledoc """
  Defines logs schema and CRUD functions
  """
  alias Auth.Repo
  import Ecto.Changeset
  use Ecto.Schema
  require Logger

  schema "logs" do
    field :app_id, :id
    field :email, Fields.Encrypted
    field :msg, :string
    field :person_id, :id
    field :request_path, Fields.Encrypted
    field :status_id, :id
    field :user_agent_id, :id
    timestamps()
  end

  @doc false
  def changeset(login_log, attrs) do
    cast(login_log, attrs, [:app_id, :email, :msg, :person_id, :request_path, :status_id, :user_agent_id])
  end

  def insert_log(log) do
    %Auth.Log{}
    |> changeset(log)
    |> Repo.insert!()
  end

  # def get_by_id(id) do
  #   Repo.get_by(__MODULE__, id: id)
  # end

  def get_all() do
    Repo.all(__MODULE__)
  end

  def insert(conn, params) do
    insert_log(
      Map.merge(params, %{
        app_id: Map.get(params, :app_id, 1),
        auth_provider: get_auth_provider(conn, params),
        person_id: get_person_id(conn, params),
        request_path: conn.request_path,
        user_agent_id: get_user_agent_id(conn),
        email: get_email(conn, params)
      })
    )
    # return conn so we can pipline the log
    conn
  end

  def info(conn, params) do
    Logger.info(stringify_conn_params(conn, params))
    insert(conn, params)
  end

  def error(conn, params) do
    Logger.error(stringify_conn_params(conn, params))
    insert(conn, params)
  end

  defp get_user_agent_id(conn) do
    if Map.has_key?(conn.assigns, :ua) do
      # user_agent string is available
      List.first(String.split(conn.assigns.ua, "|"))
    else
      # no user_agent string in conn
      ua = Auth.UserAgent.upsert(conn)
      ua.id
    end
  end

  defp get_email(conn, params) do
    if Map.has_key?(conn.assigns, :person) do
      Map.get(conn.assigns.person, :email)
    else
      Map.get(params, :email)
    end
  end

  defp stringify_conn_params(conn, params) do
    conn.method <> " " <> conn.request_path
    <> " > " <> stringify(params)
    <> " person:#{get_person_id(conn, params)}"
  end

  defp get_auth_provider(conn, params) do
    if Map.has_key?(conn.assigns, :person) do
      conn.assigns.person.auth_provider
    else
      Map.get(params, :auth_provider)
    end
  end

  defp get_person_id(conn, params) do
    if Map.has_key?(conn.assigns, :person) do
      conn.assigns.person.id
    else
      Map.get(params, :person_id)
    end
  end

  def stringify(map) when is_map(map) do
    map
    |> Map.delete(:__meta__)
    |> Map.delete(:__struct__)
    # avoid leaking personal data in logs
    |> Map.delete(:email)
    |> Map.keys()
    |> Enum.map(fn key ->
      if not is_nil(Map.get(map, key)) do
        "#{key}:#{Map.get(map, key)}"
      end
    end)
    |> Enum.filter(& !is_nil(&1))
    |> Enum.join(", ")
  end

  def stringify(map) when is_nil(map) do
    "nil"
  end
end