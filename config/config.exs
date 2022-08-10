import Config

config :esbuild,
  version: "0.14.45",
  default: [
    args: ~w(js/main.js --bundle --minify --format=esm --outdir=../lib/assets),
    cd: Path.expand("../assets", __DIR__)
  ]
