import Config

if config_env() == :dev do
  import_config("dev.secret.exs")
end
