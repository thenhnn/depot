{pkgs, ...}:
pkgs.stdenv.mkDerivation (finalAttrs: {
  pname = "helium-patches";
  version = "0.13.4";
  src = pkgs.fetchFromGitHub {
    owner = "imputnet";
    repo = "helium";
    tag = finalAttrs.version;
    hash = "sha256-cPuavundinwRCZkX5pDaG0hmB/ripn0HQ/pJmOzhv5M=";
  };

  dontBuild = true;

  buildInputs = with pkgs; [
    python3Packages.python
    patch
  ];

  nativeBuildInputs = with pkgs; [
    makeWrapper
  ];

  installPhase = ''
    mkdir $out
    cp -R * $out/
    wrapProgram $out/utils/patches.py --add-flags "apply" --prefix PATH : "${pkgs.patch}/bin"
  '';
})
