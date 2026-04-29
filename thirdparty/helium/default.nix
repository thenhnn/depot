{use, ...}: {
  pkgs,
  lib ? use "//nix/lib",
  ...
}: let
  helium-patches = import ./helium-patches.nix {inherit pkgs;};
in rec {
  inherit helium-patches;
  upstream-info = lib.importJSON ./sources.json;

  release =
    pkgs.callPackage (import ./wrapper.nix {
      inherit helium-patches;
      nixpkgsChromiumPath = "${pkgs.path}/pkgs/applications/networking/browsers/chromium";
    }) {
      inherit upstream-info;
    };
}
