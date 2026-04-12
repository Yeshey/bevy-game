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
    targets = [ "aarch64-linux-android" "wasm32-unknown-unknown" ];
  };

  android = {
    enable = true;
    ndk.enable = true;
    android-studio.enable = true;
  };

  languages.java = {
    enable = true;
    gradle.enable = true;
  };

  packages = with pkgs; [
    trunk 
    wasm-pack
    wasm-bindgen-cli
    cargo-apk
    cargo-ndk
    alsa-lib
    udev
    vulkan-loader
    vulkan-tools
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

  enterShell = ''
    adb shell settings put global verifier_verify_adb_installs 0 2>/dev/null || true
  '';
}
