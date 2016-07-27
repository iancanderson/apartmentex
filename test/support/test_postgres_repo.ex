defmodule Apartmentex.TestPostgresRepo do
  use Ecto.Repo, otp_app: :apartmentex, adapter: Ecto.Adapters.Postgres, pool: Ecto.Adapters.SQL.Sandbox
end
