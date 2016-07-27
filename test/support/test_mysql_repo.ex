defmodule Apartmentex.TestMySQLRepo do
  use Ecto.Repo, otp_app: :apartmentex, adapter: Ecto.Adapters.MySQL, pool: Ecto.Adapters.SQL.Sandbox
end
