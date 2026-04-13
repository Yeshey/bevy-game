{
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [ ./devenv-common.nix ];

  android = {
    enable = true;
    ndk.enable = true;
    android-studio.enable = true;
  };

  languages.java = {
    enable = true;
    gradle.enable = true;
  };

  languages.rust.targets = [ "aarch64-linux-android" ];

  packages = with pkgs; [
    cargo-apk
    cargo-ndk
    vulkan-tools
  ];

  enterShell = ''
    adb shell settings put global verifier_verify_adb_installs 0 2>/dev/null || true
  '';

  profiles.web.module = ./devenv-common.nix;
}