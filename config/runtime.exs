import Config

if System.get_env("PHX_SERVER") && System.get_env("RELEASE_NAME") do
  config :twiddle, TwiddleWeb.Endpoint, server: true
end

ffmpeg_bin = System.get_env("FFMPEG_BIN") || System.find_executable("ffmpeg")
config :twiddle, Twiddle.FFmpeg, binary: ffmpeg_bin
config :twiddle, :config_file, System.get_env("CONFIG_FILE", "config.yaml")

if config_env() == :prod do
  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  config :twiddle, TwiddleWeb.Endpoint,
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: String.to_integer(System.get_env("PORT") || "4000")
    ],
    secret_key_base: secret_key_base

  # ## Using releases
  #
  # If you are doing OTP releases, you need to instruct Phoenix
  # to start each relevant endpoint:
  #
  #     config :twiddle, TwiddleWeb.Endpoint, server: true
  #
  # Then you can assemble a release by calling `mix release`.
  # See `mix help release` for more information.
end
