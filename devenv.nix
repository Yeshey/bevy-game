# devenv.nix
{
  pkgs,
  lib,
  config,
  ...
}:
{
  # Common tools needed for ALL profiles
  imports = [ ./devenv-common.nix ];

  # Full dev environment (default, local)
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
    cargo-apk
    cargo-ndk
    vulkan-tools
  ];

  enterShell = ''
    adb shell settings put global verifier_verify_adb_installs 0 2>/dev/null || true
  '';

  # Web-only profile for CI
  profiles.web = {
    imports = [ ./devenv-common.nix ];
  };
}