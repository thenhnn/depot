{pkgs, ...}:
pkgs.stdenv.mkDerivation {
  pname = "helium-patches";
  version = "0.13.1";
  src = pkgs.fetchFromGitHub {
    owner = "imputnet";
    repo = "helium";
    rev = "5bf45fed697113e0c5b1d47354c98f8d24a6d07a";
    hash = "sha256-hDnbVL6kITzdnqjS3WHbILDWrgMQbtWVPHSMVoX6gU0=";
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
}
