{use, ...}: {
  pkgs,
  lib ? use "//nix/lib",
  ...
}: let
  ungoogler = import ./patched-ungoogler.nix {
    ungoogledRev = {
      owner = "imputnet";
      repo = "helium";
      rev = "df2f950984dc3061f9cbd6d19285f0cfd4429531";
      hash = "sha256-C8hfVHOK7MeTJ6M0c/EXwAQww4QtNlvR2pafDEb5ZoM=";
    };
    inherit pkgs use;
  };
in rec {
  inherit ungoogler;

  upstream-info = lib.importJSON ./sources.json;

  chromium-esbuild = let
    pkg = {
      buildGoModule,
      fetchFromGitHub,
      lib,
    }:
      buildGoModule rec {
        pname = "esbuild";
        version = "0.25.1";

        src = fetchFromGitHub {
          owner = "evanw";
          repo = "esbuild";
          rev = "v${version}";
          hash = "sha256-vrhtdrvrcC3dQoJM6hWq6wrGJLSiVww/CNPlL1N5kQ8=";
        };

        vendorHash = "sha256-+BfxCyg0KkDQpHt/wycy/8CTG6YBA/VJvJFhhzUnSiQ=";

        subPackages = ["cmd/esbuild"];

        ldflags = [
          "-s"
          "-w"
        ];

        meta = with lib; {
          description = "Extremely fast JavaScript bundler";
          homepage = "https://esbuild.github.io";
          changelog = "https://github.com/evanw/esbuild/blob/v${version}/CHANGELOG.md";
          license = licenses.mit;
          maintainers = with maintainers; [
            lucus16
            undefined-moe
            ivan
          ];
          mainProgram = "esbuild";
        };
      };
  in
    pkgs.pkgsBuildHost.callPackage pkg {};

  release =
    pkgs.callPackage (import ./wrapper.nix {
      inherit ungoogler;
      nixpkgsChromiumPath = "${pkgs.path}/pkgs/applications/networking/browsers/chromium";
    }) {
      inherit upstream-info;
    };
}
