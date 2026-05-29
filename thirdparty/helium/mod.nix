{
  visibility = [
    "public"
  ];

  build = {
    use,
    inject,
    ...
  }: let
    lib = use "//nix/lib";
    pkgs = inject "pkgs";
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
  };
}
