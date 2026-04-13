# devenv-common.nix
{
  pkgs,
  lib,
  config,
  ...
}:
{
  languages.rust = {
    enable = true;
    channel = "stable";
    targets = [ "wasm32-unknown-unknown" ];
  };

  packages = with pkgs; [
    trunk
    binaryen
    wasm-pack
    wasm-bindgen-cli
    alsa-lib
    udev
    vulkan-loader
    libxkbcommon
    wayland
    libx11
    libxcursor
    libxi
    libxrandr
    pkg-config
    clang
    mold
  ];

  env.LD_LIBRARY_PATH = lib.makeLibraryPath (with pkgs; [
    vulkan-loader
    wayland
    libx11
    libxcursor
    libxi
    libxrandr
    libxkbcommon
  ]);
}