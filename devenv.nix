{ pkgs, lib, config, ... }:
let
  # ── Shared package sets ─────────────────────────────────────────────────
  webPkgs = with pkgs; [
    trunk binaryen wasm-pack wasm-bindgen-cli
  ];

  nativePkgs = with pkgs; [
    pkg-config clang mold
  ];

  runtimeLibs = with pkgs; [
    vulkan-loader
    libx11 libxcursor libxi libxrandr
    libxkbcommon wayland
  ];

  desktopPkgs = with pkgs; [
    alsa-lib alsa-plugins udev
  ] ++ runtimeLibs;

  # ── Shared environment ──────────────────────────────────────────────────
  libclang = pkgs.llvmPackages_latest.libclang;

  sharedEnv = {
    LIBCLANG_PATH = lib.makeLibraryPath [ libclang.lib ];

    BINDGEN_EXTRA_CLANG_ARGS = builtins.concatStringsSep " " [
      ''-I"${libclang.lib}/lib/clang/${libclang.version}/include"''
      ''-I"${pkgs.glib.dev}/include/glib-2.0"''
      ''-I"${pkgs.glib.out}/lib/glib-2.0/include"''
    ];

    LD_LIBRARY_PATH = lib.makeLibraryPath runtimeLibs;
  };

  # ── Shared rust config ──────────────────────────────────────────────────
  sharedRust = {
    enable  = true;
    channel = "stable";
  };
in
{
  # ── Rust ────────────────────────────────────────────────────────────────
  languages.rust = sharedRust // {
    targets = [ "wasm32-unknown-unknown" "aarch64-linux-android" ];
  };

  # ── Android ─────────────────────────────────────────────────────────────
  android = {
    enable                = true;
    ndk.enable            = true;
    android-studio.enable = false;
  };

  languages.java = {
    enable        = true;
    gradle.enable = true;
  };

  # ── Packages ─────────────────────────────────────────────────────────────
  packages = webPkgs ++ nativePkgs ++ desktopPkgs ++ (with pkgs; [
    cargo-apk cargo-ndk vulkan-tools
  ]);

  # ── Environment ──────────────────────────────────────────────────────────
  env = sharedEnv;

  # ── Shell hook ───────────────────────────────────────────────────────────
  enterShell = ''
    export ALSA_PLUGIN_DIR=${pkgs.alsa-plugins}/lib/alsa-lib
    adb shell settings put global verifier_verify_adb_installs 0 2>/dev/null || true
  '';

  # ── Web profile (used in CI: devenv --profile web shell -- trunk build) ──
  profiles.web.module = { pkgs, lib, ... }: {
    languages.rust = sharedRust // {
      targets = [ "wasm32-unknown-unknown" ];
    };

    packages = webPkgs ++ nativePkgs ++ desktopPkgs;

    env = sharedEnv;
  };
}