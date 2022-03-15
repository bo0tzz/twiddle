import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :twitch_autodl_web, TwitchAutodlWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "foKSZhRQvSxKbQ2sJif8zqtxv/MSLilui0itOtiySeXhfeXJG9SzUE/8UhxvxG3v",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
