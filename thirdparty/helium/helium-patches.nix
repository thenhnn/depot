{pkgs, ...}:
pkgs.stdenv.mkDerivation {
  pname = "helium-patches";
  version = "0.12.4";
  src = pkgs.fetchFromGitHub {
    owner = "imputnet";
    repo = "helium";
    rev = "b4155a785863b8b7ef05b8efd414041c4b49d2c3";
    hash = "sha256-zlxk1qnYu3pMpJhFEdOS8MaHbufKg4BwuJnfdU/D6Fs=";
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
