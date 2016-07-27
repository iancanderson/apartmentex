Code.compiler_options(ignore_module_conflict: true)

Mix.Task.run "ecto.drop", ["quiet", "-r", "Apartmentex.TestPostgresRepo"]
Mix.Task.run "ecto.create", ["quiet", "-r", "Apartmentex.TestPostgresRepo"]
Mix.Task.run "ecto.drop", ["quiet", "-r", "Apartmentex.TestMySQLRepo"]
Mix.Task.run "ecto.create", ["quiet", "-r", "Apartmentex.TestMySQLRepo"]

Apartmentex.TestMySQLRepo.start_link
Apartmentex.TestPostgresRepo.start_link

ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(Apartmentex.TestPostgresRepo, :manual)
Ecto.Adapters.SQL.Sandbox.mode(Apartmentex.TestMySQLRepo, :manual)
