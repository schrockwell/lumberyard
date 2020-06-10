defmodule Lumber.Admin do
  def authenticated?(credentials) do
    credentials["password"] == System.get_env("ADMIN_PASSWORD", "password")
  end
end
